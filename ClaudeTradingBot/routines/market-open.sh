#!/usr/bin/env bash
# market-open.sh - Cron-driven market-open PREP routine.
# Faithful to routines/market-open.md, mechanical/prep half only.
# Runs Mon-Fri 08:31 America/Chicago (skips US market holidays via clock).
#
# This script PLACES NO ORDERS. It collects everything the agent turn
# needs to evaluate today's trade ideas and execute them safely.
#
# Steps:
#   1. Ensure env (cron starts empty: load .env, set PATH).
#   2. Verify required env vars.
#   3. Market clock guard — exit clean if market is closed (weekend/holiday).
#   4. Read today's RESEARCH-LOG entry; if NONE / missing, write noop.flag.
#   5. Pull live Alpaca account / positions / orders.
#   6. Parse candidate tickers from today's Trade Ideas section; pull
#      a quote for each.
#   7. Compute weekly trade count from TRADE-LOG.md tail.
#   8. Persist prep.json + raw artifacts under
#      logs/market-open-prep-YYYY-MM-DD/ for the agent turn.
#   9. Telegram only on infrastructure failure.
#
# The agent turn (separate cron payload) reads the prep dir, applies
# hard-check rules, places orders, logs trades, telegrams, and commits.
#
# Logs: ClaudeTradingBot/logs/market-open-YYYY-MM-DD.log
# Prep dir: ClaudeTradingBot/logs/market-open-prep-YYYY-MM-DD/

set -uo pipefail

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

# --- Logging ---
mkdir -p "$ROOT/logs"
DATE=$(date +%Y-%m-%d)
TS=$(date "+%Y-%m-%d %H:%M:%S %Z")
LOG_FILE="$ROOT/logs/market-open-$DATE.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "==== market-open.sh start $TS ===="

# --- Single-run lock ---
LOCK="$ROOT/logs/market-open.lock"
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

if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new"
elif [[ -f "$HOME/.ssh/id_rsa" ]]; then
  export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_rsa -o StrictHostKeyChecking=accept-new"
fi

# --- Step 0: env verification ---
echo "---- env check ----"
missing=0
for v in ALPACA_PAPER_KEY ALPACA_SECRET_KEY PERPLEXITY_API_KEY TELEGRAM_TOKEN CHAT_ID NEON_URL; do
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
    bash "$ROOT/scripts/telegram.sh" "market-open $DATE: missing required env var(s); aborted." || true
  fi
  exit 1
fi

# --- Prep dir ---
PREP_DIR="$ROOT/logs/market-open-prep-$DATE"
rm -rf "$PREP_DIR"
mkdir -p "$PREP_DIR"
echo "prep dir: $PREP_DIR"

# --- Step 1: Market clock guard ---
echo "---- market clock ----"
CLOCK_JSON=$(bash "$ROOT/scripts/alpaca.sh" clock 2>&1) || {
  echo "alpaca clock FAILED: $CLOCK_JSON"
  bash "$ROOT/scripts/telegram.sh" "market-open $DATE: alpaca clock failed; aborted." || true
  exit 2
}
echo "$CLOCK_JSON"
printf '%s' "$CLOCK_JSON" > "$PREP_DIR/clock.json"
IS_OPEN=$(python3 -c "import json,sys; d=json.loads('''$CLOCK_JSON'''); print('true' if d.get('is_open') else 'false')")
echo "is_open=$IS_OPEN"
if [[ "$IS_OPEN" != "true" ]]; then
  echo "market closed (weekend/holiday/pre-open). Writing closed.flag and exiting clean."
  : > "$PREP_DIR/closed.flag"
  echo "==== market-open.sh end (closed) $(date "+%Y-%m-%d %H:%M:%S %Z") ===="
  exit 0
fi

# --- Step 2: Memory presence ---
echo "---- memory files ----"
for f in TRADING-STRATEGY.md TRADE-LOG.md RESEARCH-LOG.md; do
  if [[ -f "$ROOT/memory/$f" ]]; then
    echo "$f: $(wc -l < "$ROOT/memory/$f") lines"
  else
    echo "$f: MISSING"
    bash "$ROOT/scripts/telegram.sh" "market-open $DATE: memory/$f missing; aborted." || true
    exit 3
  fi
done

# --- Step 3: Extract today's RESEARCH-LOG entry + Trade Ideas section ---
echo "---- research-log slice ----"
python3 - "$ROOT/memory/RESEARCH-LOG.md" "$DATE" "$PREP_DIR" <<'PY'
import sys, re, pathlib, json
log_path, date, prep_dir = sys.argv[1], sys.argv[2], pathlib.Path(sys.argv[3])
text = pathlib.Path(log_path).read_text()
# Find today's entry header. Format from pre-market.sh:
# "## YYYY-MM-DD — Pre-market Research (cron HH:MM TZ)"
header_re = re.compile(rf"^## {re.escape(date)} —", re.MULTILINE)
m = header_re.search(text)
if not m:
    (prep_dir / "ideas_status.txt").write_text("MISSING_TODAY")
    print(f"no entry for {date} in RESEARCH-LOG.md")
    sys.exit(0)
start = m.start()
# Slice to next "## " header or EOF
nxt = re.search(r"^## ", text[start+1:], re.MULTILINE)
end = (start + 1 + nxt.start()) if nxt else len(text)
entry = text[start:end]
(prep_dir / "today_research.md").write_text(entry)
# Extract Trade Ideas section. Agent appends a "### Trade Ideas" subsection.
# Accept "### Trade Ideas" optionally followed by qualifier (e.g. "(agent-synthesized)").
ideas_re = re.compile(r"^### Trade Ideas[^\n]*\n([\s\S]*?)(?=^### |\Z)", re.MULTILINE)
im = ideas_re.search(entry)
if not im:
    (prep_dir / "ideas_status.txt").write_text("NO_IDEAS_SECTION")
    print("today entry found but no Trade Ideas section yet")
    sys.exit(0)
ideas_body = im.group(1).strip()
(prep_dir / "ideas.md").write_text(ideas_body)
# Detect explicit NONE pattern.
if re.search(r"^NONE\b", ideas_body, re.IGNORECASE | re.MULTILINE) or "patience > activity" in ideas_body.lower():
    (prep_dir / "ideas_status.txt").write_text("NONE")
    print("Trade Ideas section: NONE — patience > activity")
    sys.exit(0)
# Extract candidate tickers. Format the agent writes:
#   N. **TICKER** — sector
ticker_re = re.compile(r"^\s*\d+\.\s*\*\*([A-Z][A-Z0-9.\-]{0,9})\*\*", re.MULTILINE)
tickers = []
for tm in ticker_re.finditer(ideas_body):
    t = tm.group(1)
    if t not in tickers:
        tickers.append(t)
(prep_dir / "tickers.json").write_text(json.dumps(tickers))
(prep_dir / "ideas_status.txt").write_text("HAVE_IDEAS" if tickers else "NO_TICKERS_PARSED")
print(f"parsed tickers: {tickers}")
PY

IDEAS_STATUS=$(cat "$PREP_DIR/ideas_status.txt" 2>/dev/null || echo "UNKNOWN")
echo "ideas_status=$IDEAS_STATUS"

if [[ "$IDEAS_STATUS" != "HAVE_IDEAS" ]]; then
  echo "no actionable ideas; writing noop.flag"
  : > "$PREP_DIR/noop.flag"
  # Continue to pull account state anyway so the agent can write a noop
  # trade-log entry with accurate equity/positions, but skip per-ticker
  # quotes since there are no tickers.
fi

# --- Step 4: Alpaca live state ---
echo "---- alpaca account ----"
ACCOUNT_JSON=$(bash "$ROOT/scripts/alpaca.sh" account 2>&1) || {
  echo "alpaca account FAILED: $ACCOUNT_JSON"
  bash "$ROOT/scripts/telegram.sh" "market-open $DATE: alpaca account failed; aborted." || true
  exit 4
}
printf '%s' "$ACCOUNT_JSON" > "$PREP_DIR/account.json"
POSITIONS_JSON=$(bash "$ROOT/scripts/alpaca.sh" positions 2>&1) || {
  echo "alpaca positions FAILED: $POSITIONS_JSON"
  bash "$ROOT/scripts/telegram.sh" "market-open $DATE: alpaca positions failed; aborted." || true
  exit 4
}
printf '%s' "$POSITIONS_JSON" > "$PREP_DIR/positions.json"
ORDERS_JSON=$(bash "$ROOT/scripts/alpaca.sh" orders 2>&1) || {
  echo "alpaca orders FAILED: $ORDERS_JSON"
  bash "$ROOT/scripts/telegram.sh" "market-open $DATE: alpaca orders failed; aborted." || true
  exit 4
}
printf '%s' "$ORDERS_JSON" > "$PREP_DIR/orders.json"

read -r EQUITY CASH BP DTC PDT POSITIONS_COUNT ORDERS_COUNT < <(python3 - <<PY
import json
acct = json.loads('''$ACCOUNT_JSON''')
pos = json.loads('''$POSITIONS_JSON''')
ords = json.loads('''$ORDERS_JSON''')
print(
  acct.get("equity",""), acct.get("cash",""), acct.get("buying_power",""),
  acct.get("daytrade_count",""), acct.get("pattern_day_trader",""),
  len(pos) if isinstance(pos, list) else "err",
  len(ords) if isinstance(ords, list) else "err",
)
PY
) || true
echo "parsed: equity=$EQUITY cash=$CASH bp=$BP dtc=$DTC pdt=$PDT positions=$POSITIONS_COUNT orders=$ORDERS_COUNT"

# --- Step 5: Per-ticker quotes (only if we have ideas) ---
if [[ "$IDEAS_STATUS" == "HAVE_IDEAS" ]]; then
  echo "---- per-ticker quotes ----"
  TICKERS=$(python3 -c "import json; print(' '.join(json.load(open('$PREP_DIR/tickers.json'))))")
  QUOTE_FAIL=0
  mkdir -p "$PREP_DIR/quotes"
  for sym in $TICKERS; do
    out="$PREP_DIR/quotes/$sym.json"
    err="$PREP_DIR/quotes/$sym.err"
    if bash "$ROOT/scripts/alpaca.sh" quote "$sym" > "$out" 2> "$err"; then
      echo "quote $sym ok ($(wc -c < "$out") bytes)"
    else
      rc=$?
      QUOTE_FAIL=$((QUOTE_FAIL+1))
      echo "quote $sym FAILED rc=$rc: $(head -c 200 "$err")"
    fi
  done
else
  QUOTE_FAIL=0
  TICKERS=""
fi

# --- Step 6: Weekly trade count from TRADE-LOG.md ---
WEEKLY_TRADES=$(python3 - "$ROOT/memory/TRADE-LOG.md" "$DATE" <<'PY'
import sys, re, pathlib, datetime as dt
path, date = sys.argv[1], sys.argv[2]
text = pathlib.Path(path).read_text()
today = dt.date.fromisoformat(date)
# Match any ISO date that appears in the log; count entries within last 7d
# that look like a trade row (must contain "buy" or "BUY" near the date).
# This is intentionally loose — agent-side will recompute precisely if it
# matters for the rule check.
count = 0
for line in text.splitlines():
    m = re.search(r"(\d{4}-\d{2}-\d{2})", line)
    if not m: continue
    try:
        d = dt.date.fromisoformat(m.group(1))
    except ValueError:
        continue
    if 0 <= (today - d).days <= 6:
        if re.search(r"\bbuy\b", line, re.IGNORECASE):
            count += 1
print(count)
PY
)
echo "weekly_trades_last7d=$WEEKLY_TRADES"

# --- Step 7: Persist prep.json ---
cat > "$PREP_DIR/prep.json" <<EOF_PREP
{
  "date": "$DATE",
  "timestamp": "$TS",
  "is_open": $IS_OPEN,
  "ideas_status": "$IDEAS_STATUS",
  "tickers": $(cat "$PREP_DIR/tickers.json" 2>/dev/null || echo "[]"),
  "quote_fail": $QUOTE_FAIL,
  "equity": "$EQUITY",
  "cash": "$CASH",
  "buying_power": "$BP",
  "daytrade_count": "$DTC",
  "pattern_day_trader": "$PDT",
  "positions_count": $POSITIONS_COUNT,
  "orders_count": $ORDERS_COUNT,
  "weekly_trades_last7d": $WEEKLY_TRADES,
  "capital_cap_usd": 10000,
  "max_position_pct": 20,
  "max_positions": 6,
  "max_weekly_trades": 3
}
EOF_PREP
echo "---- prep.json ----"
cat "$PREP_DIR/prep.json"

# --- Step 8: Script-side telegram (infra only) ---
if (( QUOTE_FAIL > 0 )); then
  bash "$ROOT/scripts/telegram.sh" "market-open $DATE: $QUOTE_FAIL quote(s) failed; agent will skip those." || true
fi

echo "==== market-open.sh end $(date "+%Y-%m-%d %H:%M:%S %Z") ===="
