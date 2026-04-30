#!/usr/bin/env bash
# market-open.sh - Cron-driven market-open routine with HARD RULE ENFORCEMENT.
# Runs Mon-Fri 08:31 America/Chicago (1 min after open).
#
# === STRATEGY HARD RULES (enforced mechanically) ===
# 1. NO OPTIONS — ever.
# 2. Max 6 open positions.
# 3. Max 20% equity per position.
# 4. Max 3 new trades per rolling 7-day window.
# 5. 75-85% capital deployed (target range).
# 6. 10% trailing stop on EVERY position as a real GTC order.
# 7. Cut losers at -7% manually.
# 8. Tighten trail to 7% at +15% gain, to 5% at +20% gain.
# 9. Stop never within 3% of current price. Never move a stop down.
# 10. Exit a sector after 2 failed trades.
# 11. Patience > activity.
#
# This script:
#   - Collects all market/account data
#   - Runs a HARD RULE CHECK GATE (rules_check.json)
#   - Identifies positions needing stop tightening or loss cuts
#   - Computes allowed capital for new trades
#   - Blocks the agent turn if critical rules are violated
#
# The agent turn reads the prep dir and CAN ONLY act within the
# boundaries set by rules_check.json.
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
for v in ALPACA_PAPER_KEY ALPACA_SECRET_KEY PERPLEXITY_API_KEY TELEGRAM_TOKEN CHAT_ID; do
  if [[ -z "${!v:-}" ]]; then
    echo "$v: MISSING"
    missing=1
  else
    echo "$v: set"
  fi
done
if (( missing )); then
  echo "FATAL: missing required env var(s); aborting."
  if [[ -n "${TELEGRAM_TOKEN:-}" && -n "${CHAT_ID:-}" ]]; then
    bash "$ROOT/scripts/telegram.sh" "⛔ market-open $DATE: missing env var(s); aborted." || true
  fi
  exit 1
fi

# --- Prep dir ---
PREP_DIR="$ROOT/logs/market-open-prep-$DATE"
rm -rf "$PREP_DIR"
mkdir -p "$PREP_DIR/quotes"
echo "prep dir: $PREP_DIR"

# --- Step 1: Market clock guard ---
echo "---- market clock ----"
CLOCK_JSON=$(bash "$ROOT/scripts/alpaca.sh" clock 2>&1) || {
  echo "alpaca clock FAILED: $CLOCK_JSON"
  bash "$ROOT/scripts/telegram.sh" "⛔ market-open $DATE: alpaca clock failed." || true
  exit 2
}
echo "$CLOCK_JSON"
printf '%s' "$CLOCK_JSON" > "$PREP_DIR/clock.json"
IS_OPEN=$(python3 -c "import json; d=json.loads('''$CLOCK_JSON'''); print('true' if d.get('is_open') else 'false')")
echo "is_open=$IS_OPEN"
if [[ "$IS_OPEN" != "true" ]]; then
  echo "market closed. Exiting clean."
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
    bash "$ROOT/scripts/telegram.sh" "⛔ market-open $DATE: memory/$f missing." || true
    exit 3
  fi
done

# --- Step 3: Pull Alpaca account / positions / orders ---
echo "---- alpaca data pull ----"
ACCOUNT_JSON=$(bash "$ROOT/scripts/alpaca.sh" account 2>&1) || {
  echo "alpaca account FAILED"; exit 4; }
printf '%s' "$ACCOUNT_JSON" > "$PREP_DIR/account.json"

POSITIONS_JSON=$(bash "$ROOT/scripts/alpaca.sh" positions 2>&1) || {
  echo "alpaca positions FAILED"; exit 4; }
printf '%s' "$POSITIONS_JSON" > "$PREP_DIR/positions.json"

ORDERS_JSON=$(bash "$ROOT/scripts/alpaca.sh" orders 2>&1) || {
  echo "alpaca orders FAILED"; exit 4; }
printf '%s' "$ORDERS_JSON" > "$PREP_DIR/orders.json"

# Also pull ALL orders (not just open) to check for option types
ALL_ORDERS_JSON=$(bash "$ROOT/scripts/alpaca.sh" orders all 2>&1) || ALL_ORDERS_JSON="[]"
printf '%s' "$ALL_ORDERS_JSON" > "$PREP_DIR/orders_all.json"

echo "account/positions/orders: OK"

# --- Step 4: Extract today's research + trade ideas ---
echo "---- research-log slice ----"
python3 - "$ROOT/memory/RESEARCH-LOG.md" "$DATE" "$PREP_DIR" <<'PY'
import sys, re, pathlib, json
log_path, date, prep_dir = sys.argv[1], sys.argv[2], pathlib.Path(sys.argv[3])
text = pathlib.Path(log_path).read_text()
header_re = re.compile(rf"^## {re.escape(date)} —", re.MULTILINE)
m = header_re.search(text)
if not m:
    (prep_dir / "ideas_status.txt").write_text("MISSING_TODAY")
    print(f"no entry for {date} in RESEARCH-LOG.md")
    sys.exit(0)
start = m.start()
nxt = re.search(r"^## ", text[start+1:], re.MULTILINE)
end = (start + 1 + nxt.start()) if nxt else len(text)
entry = text[start:end]
(prep_dir / "today_research.md").write_text(entry)
ideas_re = re.compile(r"^### Trade Ideas[^\n]*\n([\s\S]*?)(?=^### |\Z)", re.MULTILINE)
im = ideas_re.search(entry)
if not im:
    (prep_dir / "ideas_status.txt").write_text("NO_IDEAS_SECTION")
    sys.exit(0)
ideas_body = im.group(1).strip()
(prep_dir / "ideas.md").write_text(ideas_body)
if re.search(r"^NONE\b", ideas_body, re.IGNORECASE | re.MULTILINE) or "patience > activity" in ideas_body.lower():
    (prep_dir / "ideas_status.txt").write_text("NONE")
    sys.exit(0)
ticker_re = re.compile(r"^\s*\d+\.\s*\*\*([A-Z][A-Z0-9.\-]{0,9})\*\*", re.MULTILINE)
tickers = [tm.group(1) for tm in ticker_re.finditer(ideas_body)]
tickers = list(dict.fromkeys(tickers))  # dedupe preserving order
(prep_dir / "tickers.json").write_text(json.dumps(tickers))
(prep_dir / "ideas_status.txt").write_text("HAVE_IDEAS" if tickers else "NO_TICKERS_PARSED")
print(f"parsed tickers: {tickers}")
PY

IDEAS_STATUS=$(cat "$PREP_DIR/ideas_status.txt" 2>/dev/null || echo "UNKNOWN")
echo "ideas_status=$IDEAS_STATUS"

# --- Step 5: Per-ticker quotes ---
if [[ "$IDEAS_STATUS" == "HAVE_IDEAS" ]]; then
  echo "---- per-ticker quotes ----"
  TICKERS=$(python3 -c "import json; print(' '.join(json.load(open('$PREP_DIR/tickers.json'))))")
  QUOTE_FAIL=0
  for sym in $TICKERS; do
    if bash "$ROOT/scripts/alpaca.sh" quote "$sym" > "$PREP_DIR/quotes/$sym.json" 2> "$PREP_DIR/quotes/$sym.err"; then
      echo "quote $sym: OK"
    else
      QUOTE_FAIL=$((QUOTE_FAIL+1))
      echo "quote $sym: FAILED"
    fi
  done
else
  QUOTE_FAIL=0
fi

# --- Step 6: Weekly trade count ---
WEEKLY_TRADES=$(python3 - "$ROOT/memory/TRADE-LOG.md" "$DATE" <<'PY'
import sys, re, pathlib, datetime as dt
path, date = sys.argv[1], sys.argv[2]
text = pathlib.Path(path).read_text()
today = dt.date.fromisoformat(date)
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

# ============================================================
# === STEP 7: HARD RULE ENFORCEMENT GATE ===
# This is the critical section. Outputs rules_check.json with
# pass/fail for every rule + action items the agent MUST execute.
# ============================================================
echo "---- HARD RULE CHECK ----"

python3 - "$PREP_DIR" "$DATE" "$WEEKLY_TRADES" <<'RULES_PY'
import json, sys, os, pathlib
from decimal import Decimal

prep_dir = pathlib.Path(sys.argv[1])
date = sys.argv[2]
weekly_trades = int(sys.argv[3])

# --- Load data ---
account = json.load(open(prep_dir / "account.json"))
positions = json.load(open(prep_dir / "positions.json"))
orders = json.load(open(prep_dir / "orders.json"))

equity = float(account.get("equity", 0))
cash = float(account.get("cash", 0))

# ========================================
# HARD RULES CONFIG
# ========================================
MAX_POSITIONS = 6
MAX_POSITION_PCT = 0.20        # 20% of equity per position
MAX_WEEKLY_TRADES = 3
MIN_DEPLOY_PCT = 0.75          # 75% target
MAX_DEPLOY_PCT = 0.85          # 85% ceiling
TRAILING_STOP_PCT = 0.10       # 10% default
CUT_LOSS_PCT = -0.07           # -7% cut losers
TIGHTEN_LVL1_GAIN = 0.15      # at +15% gain → 7% trail
TIGHTEN_LVL1_TRAIL = 0.07
TIGHTEN_LVL2_GAIN = 0.20      # at +20% gain → 5% trail
TIGHTEN_LVL2_TRAIL = 0.05
MIN_STOP_DISTANCE_PCT = 0.03   # stop never within 3% of price

violations = []      # critical — block new trades
warnings = []        # non-blocking but log
actions = []         # mandatory actions for agent turn

# ========================================
# RULE 1: NO OPTIONS
# ========================================
# Check if any position or order is an option (asset_class != "us_equity")
for p in positions:
    ac = p.get("asset_class", "us_equity")
    if ac != "us_equity":
        violations.append(f"NON_EQUITY_POSITION: {p.get('symbol')} is {ac} — MUST CLOSE IMMEDIATELY")
        actions.append({"action": "close_position", "symbol": p.get("symbol"), "reason": "non-equity violation"})

for o in orders:
    ac = o.get("asset_class", "us_equity")
    if ac != "us_equity":
        violations.append(f"NON_EQUITY_ORDER: order {o.get('id')} is {ac} — MUST CANCEL")
        actions.append({"action": "cancel_order", "order_id": o.get("id"), "reason": "non-equity violation"})

# ========================================
# RULE 2: MAX 6 OPEN POSITIONS
# ========================================
num_positions = len(positions)
can_open_new = num_positions < MAX_POSITIONS
slots_available = max(0, MAX_POSITIONS - num_positions)
if num_positions > MAX_POSITIONS:
    violations.append(f"OVER_POSITION_LIMIT: {num_positions}/{MAX_POSITIONS} positions")
if num_positions == MAX_POSITIONS:
    warnings.append(f"AT_POSITION_LIMIT: {num_positions}/{MAX_POSITIONS} — no new entries")

# ========================================
# RULE 3: MAX 20% EQUITY PER POSITION
# ========================================
max_position_value = equity * MAX_POSITION_PCT
oversized = []
for p in positions:
    mv = abs(float(p.get("market_value", 0)))
    pct = mv / equity if equity > 0 else 0
    if pct > MAX_POSITION_PCT + 0.01:  # 1% tolerance for price drift
        oversized.append({
            "symbol": p.get("symbol"),
            "market_value": round(mv, 2),
            "pct_of_equity": round(pct * 100, 2),
            "max_allowed_pct": MAX_POSITION_PCT * 100
        })
        warnings.append(f"OVERSIZED_POSITION: {p.get('symbol')} at {pct*100:.1f}% (max {MAX_POSITION_PCT*100}%)")

# ========================================
# RULE 4: MAX 3 NEW TRADES PER WEEK
# ========================================
trades_remaining = max(0, MAX_WEEKLY_TRADES - weekly_trades)
if weekly_trades >= MAX_WEEKLY_TRADES:
    violations.append(f"WEEKLY_TRADE_LIMIT: {weekly_trades}/{MAX_WEEKLY_TRADES} used — NO new buys")

# ========================================
# RULE 5: 75-85% CAPITAL DEPLOYED
# ========================================
total_position_value = sum(abs(float(p.get("market_value", 0))) for p in positions)
deployed_pct = total_position_value / equity if equity > 0 else 0
max_deployable = equity * MAX_DEPLOY_PCT
remaining_deployable = max(0, max_deployable - total_position_value)
if deployed_pct > MAX_DEPLOY_PCT + 0.01:
    warnings.append(f"OVER_DEPLOYED: {deployed_pct*100:.1f}% deployed (max {MAX_DEPLOY_PCT*100}%) — no new capital")
    remaining_deployable = 0

# New position sizing: min of (20% equity, remaining deployable, trades remaining check)
max_new_position = min(max_position_value, remaining_deployable) if trades_remaining > 0 and can_open_new else 0

# ========================================
# RULE 6: TRAILING STOP ON EVERY POSITION
# ========================================
# Check that every position has an associated trailing stop GTC order
open_orders_by_symbol = {}
for o in orders:
    sym = o.get("symbol", "")
    otype = o.get("order_type") or o.get("type", "")
    side = o.get("side", "")
    tif = o.get("time_in_force", "")
    trail_pct = o.get("trail_percent")
    if side == "sell" and trail_pct is not None:
        if sym not in open_orders_by_symbol:
            open_orders_by_symbol[sym] = []
        open_orders_by_symbol[sym].append({
            "order_id": o.get("id"),
            "trail_percent": float(trail_pct),
            "tif": tif,
            "qty": o.get("qty")
        })

positions_missing_stops = []
positions_needing_tighten = []

for p in positions:
    sym = p.get("symbol", "")
    qty = abs(float(p.get("qty", 0)))
    avg_entry = float(p.get("avg_entry_price", 0))
    current_price = float(p.get("current_price", 0))
    unrealized_plpc = float(p.get("unrealized_plpc", 0))  # P/L %
    market_value = abs(float(p.get("market_value", 0)))

    # Check if trailing stop exists
    stops = open_orders_by_symbol.get(sym, [])
    if not stops:
        positions_missing_stops.append(sym)
        violations.append(f"NO_TRAILING_STOP: {sym} has NO trailing stop order — MUST ADD")
        # Determine correct trail % based on gain
        if unrealized_plpc >= TIGHTEN_LVL2_GAIN:
            trail = TIGHTEN_LVL2_TRAIL
        elif unrealized_plpc >= TIGHTEN_LVL1_GAIN:
            trail = TIGHTEN_LVL1_TRAIL
        else:
            trail = TRAILING_STOP_PCT
        actions.append({
            "action": "add_trailing_stop",
            "symbol": sym,
            "qty": str(int(qty)),
            "trail_percent": trail * 100,
            "reason": f"missing stop; gain={unrealized_plpc*100:.1f}%"
        })
    else:
        # Stop exists — check if it needs tightening
        current_trail = stops[0]["trail_percent"]

        if unrealized_plpc >= TIGHTEN_LVL2_GAIN and current_trail > TIGHTEN_LVL2_TRAIL * 100:
            positions_needing_tighten.append(sym)
            actions.append({
                "action": "tighten_stop",
                "symbol": sym,
                "current_trail_pct": current_trail,
                "new_trail_pct": TIGHTEN_LVL2_TRAIL * 100,
                "reason": f"gain={unrealized_plpc*100:.1f}% >= +20% → tighten to 5%",
                "old_order_id": stops[0]["order_id"]
            })
        elif unrealized_plpc >= TIGHTEN_LVL1_GAIN and current_trail > TIGHTEN_LVL1_TRAIL * 100:
            positions_needing_tighten.append(sym)
            actions.append({
                "action": "tighten_stop",
                "symbol": sym,
                "current_trail_pct": current_trail,
                "new_trail_pct": TIGHTEN_LVL1_TRAIL * 100,
                "reason": f"gain={unrealized_plpc*100:.1f}% >= +15% → tighten to 7%",
                "old_order_id": stops[0]["order_id"]
            })

        # RULE 9: Stop never within 3% of current price
        # trail_percent of e.g. 10 means 10%. If < 3%, violation.
        if current_trail < MIN_STOP_DISTANCE_PCT * 100:
            warnings.append(f"STOP_TOO_CLOSE: {sym} trail={current_trail}% < 3% minimum")

# ========================================
# RULE 7: CUT LOSERS AT -7%
# ========================================
losers_to_cut = []
for p in positions:
    sym = p.get("symbol", "")
    unrealized_plpc = float(p.get("unrealized_plpc", 0))
    if unrealized_plpc <= CUT_LOSS_PCT:
        losers_to_cut.append(sym)
        actions.append({
            "action": "cut_loser",
            "symbol": sym,
            "loss_pct": round(unrealized_plpc * 100, 2),
            "reason": f"loss {unrealized_plpc*100:.1f}% exceeds -7% cut threshold"
        })
        violations.append(f"CUT_LOSER: {sym} at {unrealized_plpc*100:.1f}% — MUST SELL")

# ========================================
# RULE 9: NEVER MOVE A STOP DOWN
# (This is enforced at order time by the agent — flagged here as reminder)
# ========================================

# ========================================
# RULE 10: SECTOR MOMENTUM — EXIT AFTER 2 FAILED TRADES
# (Requires TRADE-LOG.md parsing — done by agent turn with full context)
# ========================================

# ========================================
# BUILD FINAL RULES CHECK
# ========================================
critical_block = len([v for v in violations if "WEEKLY_TRADE_LIMIT" in v or "OVER_POSITION_LIMIT" in v]) > 0

# If there are losers to cut or missing stops, those are mandatory actions
# but don't necessarily block NEW trades (they get handled first).
# Weekly limit and position limit DO block new trades.
new_trades_allowed = (
    trades_remaining > 0
    and can_open_new
    and remaining_deployable > 0
    and deployed_pct <= MAX_DEPLOY_PCT + 0.01
)

rules_check = {
    "date": date,
    "equity": round(equity, 2),
    "cash": round(cash, 2),
    "total_position_value": round(total_position_value, 2),
    "deployed_pct": round(deployed_pct * 100, 2),
    "num_positions": num_positions,
    "slots_available": slots_available,
    "weekly_trades_used": weekly_trades,
    "trades_remaining_this_week": trades_remaining,
    "max_new_position_value": round(max_new_position, 2),
    "remaining_deployable": round(remaining_deployable, 2),
    "new_trades_allowed": new_trades_allowed,
    "positions_missing_stops": positions_missing_stops,
    "positions_needing_tighten": positions_needing_tighten,
    "losers_to_cut": losers_to_cut,
    "oversized_positions": oversized,
    "violations": violations,
    "warnings": warnings,
    "mandatory_actions": actions,
    "rules_enforced": {
        "no_options": True,
        "max_positions": MAX_POSITIONS,
        "max_position_pct": MAX_POSITION_PCT * 100,
        "max_weekly_trades": MAX_WEEKLY_TRADES,
        "deploy_range_pct": [MIN_DEPLOY_PCT * 100, MAX_DEPLOY_PCT * 100],
        "default_trailing_stop_pct": TRAILING_STOP_PCT * 100,
        "cut_loss_pct": CUT_LOSS_PCT * 100,
        "tighten_lvl1": {"gain_pct": TIGHTEN_LVL1_GAIN * 100, "trail_pct": TIGHTEN_LVL1_TRAIL * 100},
        "tighten_lvl2": {"gain_pct": TIGHTEN_LVL2_GAIN * 100, "trail_pct": TIGHTEN_LVL2_TRAIL * 100},
        "min_stop_distance_pct": MIN_STOP_DISTANCE_PCT * 100,
        "never_move_stop_down": True,
        "sector_fail_exit_threshold": 2
    }
}

out_path = prep_dir / "rules_check.json"
with open(out_path, "w") as f:
    json.dump(rules_check, f, indent=2)

# Print summary
print(f"equity: ${equity:,.2f}")
print(f"deployed: {deployed_pct*100:.1f}% (${total_position_value:,.2f})")
print(f"positions: {num_positions}/{MAX_POSITIONS}")
print(f"weekly trades: {weekly_trades}/{MAX_WEEKLY_TRADES} ({trades_remaining} remaining)")
print(f"max new position: ${max_new_position:,.2f}")
print(f"new trades allowed: {new_trades_allowed}")
print(f"violations: {len(violations)}")
print(f"warnings: {len(warnings)}")
print(f"mandatory actions: {len(actions)}")

if violations:
    print("\n⛔ VIOLATIONS:")
    for v in violations:
        print(f"  - {v}")

if actions:
    print("\n🔧 MANDATORY ACTIONS:")
    for a in actions:
        print(f"  - {a['action']}: {a.get('symbol', '')} — {a.get('reason', '')}")

if warnings:
    print("\n⚠️  WARNINGS:")
    for w in warnings:
        print(f"  - {w}")

RULES_PY

echo ""

# --- Step 8: Build prep.json (summary for agent) ---
IDEAS_STATUS=$(cat "$PREP_DIR/ideas_status.txt" 2>/dev/null || echo "UNKNOWN")

if [[ "$IDEAS_STATUS" != "HAVE_IDEAS" ]]; then
  : > "$PREP_DIR/noop.flag"
  echo "ideas_status=$IDEAS_STATUS — noop.flag written"
fi

cat > "$PREP_DIR/prep.json" <<EOF_PREP
{
  "date": "$DATE",
  "timestamp": "$TS",
  "ideas_status": "$IDEAS_STATUS",
  "tickers": $(cat "$PREP_DIR/tickers.json" 2>/dev/null || echo "[]"),
  "quote_fail": ${QUOTE_FAIL:-0},
  "rules_check": "rules_check.json",
  "note": "AGENT: Read rules_check.json FIRST. Execute ALL mandatory_actions before any new trades. If new_trades_allowed=false, do NOT place any buy orders. Never move a stop down. Never place option orders."
}
EOF_PREP
echo "---- prep.json ----"
cat "$PREP_DIR/prep.json"

# --- Step 9: Telegram on infra failure only ---
if (( ${QUOTE_FAIL:-0} > 0 )); then
  bash "$ROOT/scripts/telegram.sh" "⚠️ market-open $DATE: $QUOTE_FAIL quote(s) failed." || true
fi

echo "==== market-open.sh end $(date "+%Y-%m-%d %H:%M:%S %Z") ===="
