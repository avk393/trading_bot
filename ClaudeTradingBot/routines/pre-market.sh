#!/usr/bin/env bash
# pre-market.sh - Cron-driven pre-market RESEARCH routine.
# Faithful to routines/pre-market.md, mechanical half only.
# Runs daily 07:30 America/Chicago.
#
# Steps:
#   1. Ensure env (cron starts empty: load .env, set PATH).
#   2. Verify required env vars.
#   3. Pull Alpaca account / positions / orders.
#   4. Run Perplexity research queries (information only, NO synthesis).
#   5. Append a dated research-only entry to memory/RESEARCH-LOG.md.
#   6. Telegram notification ONLY on infrastructure failure.
#   7. Commit + push research entry to main.
#
# Trade-idea synthesis is the agent's job (separate cron turn that reads
# the persisted research artifacts under logs/pre-market-research-DATE/
# and appends ideas + decision to RESEARCH-LOG.md as a second commit).
#
# Logs: ClaudeTradingBot/logs/pre-market-YYYY-MM-DD.log
# Research artifacts: ClaudeTradingBot/logs/pre-market-research-YYYY-MM-DD/

set -uo pipefail

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

# --- Logging ---
mkdir -p "$ROOT/logs"
DATE=$(date +%Y-%m-%d)
TS=$(date "+%Y-%m-%d %H:%M:%S %Z")
LOG_FILE="$ROOT/logs/pre-market-$DATE.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "==== pre-market.sh start $TS ===="

# --- Single-run lock ---
LOCK="$ROOT/logs/pre-market.lock"
if ! ( set -o noclobber; echo "$$" > "$LOCK" ) 2>/dev/null; then
  echo "lock $LOCK held by PID $(cat "$LOCK" 2>/dev/null) — aborting"
  exit 0
fi
trap 'rm -f "$LOCK"' EXIT

# --- Cron-safe PATH and env ---
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
if [[ -f "$ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ROOT/.env"
  set +a
fi

# Git author identity (cron has no shell config)
export GIT_AUTHOR_NAME="${GIT_AUTHOR_NAME:-${USER:-trading-bot}}"
export GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-${USER:-trading-bot}@local}"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

# SSH agent / key (cron has no agent). Use the user's default key if present.
if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new"
elif [[ -f "$HOME/.ssh/id_rsa" ]]; then
  export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_rsa -o StrictHostKeyChecking=accept-new"
fi

# --- Step 0: env verification ---
echo "---- env check ----"
missing=0
for v in ALPACA_PAPER_KEY ALPACA_SECRET_KEY PERPLEXITY_API_KEY TELEGRAM_TOKEN CHAT_ID; do
  if [[ -z "${!v:-}" ]]; then
    echo "$v: MISSING"
    missing=1
  else
    echo "$v: set"
  fi
done
if (( missing )); then
  echo "FATAL: missing required env var(s); aborting before any API call."
  if [[ -n "${TELEGRAM_TOKEN:-}" && -n "${CHAT_ID:-}" ]]; then
    bash "$ROOT/scripts/telegram.sh" "pre-market $DATE: missing required env var(s); aborted." || true
  fi
  exit 1
fi

# --- Step 1: read memory (just confirm presence) ---
echo "---- memory files ----"
for f in TRADING-STRATEGY.md TRADE-LOG.md RESEARCH-LOG.md; do
  if [[ -f "$ROOT/memory/$f" ]]; then
    echo "$f: $(wc -l < "$ROOT/memory/$f") lines"
  else
    echo "$f: MISSING"
  fi
done

# --- Step 2: Alpaca live state ---
echo "---- alpaca account ----"
ACCOUNT_JSON=$(bash "$ROOT/scripts/alpaca.sh" account 2>&1) || { echo "alpaca account FAILED: $ACCOUNT_JSON"; exit 2; }
echo "$ACCOUNT_JSON" | head -c 800; echo
POSITIONS_JSON=$(bash "$ROOT/scripts/alpaca.sh" positions 2>&1) || { echo "alpaca positions FAILED: $POSITIONS_JSON"; exit 2; }
echo "positions: $POSITIONS_JSON"
ORDERS_JSON=$(bash "$ROOT/scripts/alpaca.sh" orders 2>&1) || { echo "alpaca orders FAILED: $ORDERS_JSON"; exit 2; }
echo "orders: $ORDERS_JSON"

# Parse a few useful fields with python (jq not guaranteed)
read -r EQUITY CASH BP DTC PDT < <(python3 - <<PY
import json, sys
d = json.loads('''$ACCOUNT_JSON''')
print(d.get("equity",""), d.get("cash",""), d.get("buying_power",""), d.get("daytrade_count",""), d.get("pattern_day_trader",""))
PY
) || true

POSITIONS_COUNT=$(python3 -c "import json,sys; d=json.loads('''$POSITIONS_JSON'''); print(len(d) if isinstance(d,list) else 'err')")
ORDERS_COUNT=$(python3 -c "import json,sys; d=json.loads('''$ORDERS_JSON'''); print(len(d) if isinstance(d,list) else 'err')")

echo "parsed: equity=$EQUITY cash=$CASH bp=$BP dtc=$DTC pdt=$PDT positions=$POSITIONS_COUNT orders=$ORDERS_COUNT"

# Currently-held tickers (for step 3 ticker news)
HELD_TICKERS=$(python3 -c "import json; d=json.loads('''$POSITIONS_JSON'''); print(' '.join(p['symbol'] for p in d) if isinstance(d,list) else '')")

# --- Step 3: Perplexity research ---
# Persist artifacts so the agent turn can read them after the script exits.
RESEARCH_DIR="$ROOT/logs/pre-market-research-$DATE"
rm -rf "$RESEARCH_DIR"
mkdir -p "$RESEARCH_DIR"
echo "research dir: $RESEARCH_DIR"

queries=(
  "WTI and Brent oil price right now $DATE"
  "S&P 500 futures premarket today $DATE"
  "VIX level today $DATE"
  "Gold and rare metals $DATE"
  "Top stock market catalysts today $DATE"
  "Earnings reports today before market open $DATE"
  "Economic calendar this week CPI PPI FOMC jobs data $DATE"
  "S&P 500 sector momentum YTD $DATE"
)
if [[ -n "$HELD_TICKERS" ]]; then
  queries+=("Latest news $HELD_TICKERS today $DATE")
fi

PPLX_FAIL=0
for i in "${!queries[@]}"; do
  q="${queries[$i]}"
  out="$RESEARCH_DIR/q$((i+1)).json"
  err="$RESEARCH_DIR/q$((i+1)).err"
  if bash "$ROOT/scripts/perplexity.sh" "$q" > "$out" 2> "$err"; then
    echo "Q$((i+1)) ok ($(wc -c < "$out") bytes): $q"
  else
    rc=$?
    PPLX_FAIL=$((PPLX_FAIL+1))
    echo "Q$((i+1)) rc=$rc ($q) — $(head -c 200 "$err")"
  fi
done

# Helper: extract content from a perplexity JSON file (or print empty)
extract() {
  python3 - "$1" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
    print(d["choices"][0]["message"]["content"].strip())
except Exception as e:
    print(f"(extract error: {e})")
PY
}

# Persist parsed account state so the agent turn can read it without
# re-hitting Alpaca.
cat > "$RESEARCH_DIR/account.json" <<EOF_ACCT
{
  "date": "$DATE",
  "timestamp": "$TS",
  "equity": "$EQUITY",
  "cash": "$CASH",
  "buying_power": "$BP",
  "daytrade_count": "$DTC",
  "pattern_day_trader": "$PDT",
  "positions_count": "$POSITIONS_COUNT",
  "orders_count": "$ORDERS_COUNT",
  "held_tickers": "$HELD_TICKERS",
  "pplx_fail": $PPLX_FAIL,
  "pplx_total": ${#queries[@]}
}
EOF_ACCT
printf '%s' "$POSITIONS_JSON" > "$RESEARCH_DIR/positions.json"
printf '%s' "$ORDERS_JSON" > "$RESEARCH_DIR/orders.json"

# --- Step 4: Append RESEARCH-only entry to RESEARCH-LOG.md ---
# Trade ideas + decision are appended later by the agent turn.
TS_HM=$(date "+%H:%M %Z")
ENTRY_FILE="$RESEARCH_DIR/entry.md"
{
  echo
  echo "---"
  echo
  echo "## $DATE — Pre-market Research (cron $TS_HM)"
  echo
  echo "### Infrastructure"
  echo "- Run: cron pre-market.sh; log $LOG_FILE"
  if (( PPLX_FAIL > 0 )); then
    echo "- Perplexity: $PPLX_FAIL of ${#queries[@]} queries failed (see log)."
  else
    echo "- Perplexity: ${#queries[@]}/${#queries[@]} queries ok."
  fi
  echo "- Alpaca: account/positions/orders 200 OK."
  echo "- Branch: main."
  echo
  echo "### Account (live pull, $TS_HM)"
  echo "- Equity: \$$EQUITY"
  echo "- Cash: \$$CASH"
  echo "- Buying power: \$$BP"
  echo "- Daytrade count: $DTC; PDT flag: $PDT"
  echo "- Positions: $POSITIONS_COUNT; Open orders: $ORDERS_COUNT"
  echo "- Note: TRADING-STRATEGY.md caps deployable capital at ~\$10,000."
  echo
  echo "### Market Context — Oil"
  extract "$RESEARCH_DIR/q1.json"
  echo
  echo "### Market Context — S&P 500 Futures (premarket)"
  extract "$RESEARCH_DIR/q2.json"
  echo
  echo "### Market Context — VIX"
  extract "$RESEARCH_DIR/q3.json"
  echo
  echo "### Today's Catalysts"
  extract "$RESEARCH_DIR/q4.json"
  echo
  echo "### Earnings Before Open"
  extract "$RESEARCH_DIR/q5.json"
  echo
  echo "### Economic Calendar"
  extract "$RESEARCH_DIR/q6.json"
  echo
  echo "### Sector Momentum"
  extract "$RESEARCH_DIR/q7.json"
  if [[ -f "$RESEARCH_DIR/q8.json" ]]; then
    echo
    echo "### Held-ticker News"
    extract "$RESEARCH_DIR/q8.json"
  fi
  echo
  echo "_Research-only entry. Trade ideas + decision will be appended by the agent synthesis step._"
} > "$ENTRY_FILE"

cat "$ENTRY_FILE" >> "$ROOT/memory/RESEARCH-LOG.md"
echo "---- appended entry ($(wc -l < "$ENTRY_FILE") lines) ----"

# --- Step 5: Telegram (script-side: infrastructure failures only) ---
# The agent's synthesis turn handles action-side telegrams (ideas proposed).
if (( PPLX_FAIL > 0 )); then
  MSG="pre-market $DATE: infra failure — pplx_fail=$PPLX_FAIL/${#queries[@]}; review log."
  bash "$ROOT/scripts/telegram.sh" "$MSG" || echo "telegram send failed (continuing)"
else
  echo "telegram: silent (script side; agent handles ideas-side notify)"
fi

# --- Step 6: commit + push (research entry only) ---
echo "---- git ----"
current=$(git -C "$ROOT" branch --show-current)
echo "current branch: $current"
if [[ "$current" != "main" ]]; then
  git -C "$ROOT" checkout main || { echo "checkout main FAILED"; exit 3; }
fi

git -C "$ROOT" add memory/RESEARCH-LOG.md
if git -C "$ROOT" diff --cached --quiet; then
  echo "nothing to commit"
else
  git -C "$ROOT" commit -m "pre-market research $DATE (data only)"
  if ! git -C "$ROOT" push origin main; then
    echo "push failed; rebasing and retrying"
    git -C "$ROOT" fetch origin
    git -C "$ROOT" pull --rebase origin main
    git -C "$ROOT" push origin main
  fi
fi

echo "==== pre-market.sh end $(date "+%Y-%m-%d %H:%M:%S %Z") ===="
