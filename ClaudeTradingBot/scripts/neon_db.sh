#!/bin/bash
# Usage: bash scripts/neon_db.sh "<tickers,shares,fill_prices>"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  source "$ENV_FILE"
  set +a
fi

: "${NEON_URL:?NEON_URL not set in environment}"

INPUT="${1:?Usage: bash scripts/neon_db.sh '<tickers,shares,fill_prices>'}"

IFS=',' read -r TICKERS SHARES FILL_PRICES <<< "$INPUT"

psql "$NEON_URL" <<EOF
INSERT INTO basic (tckr, shares, fill_price) VALUES ('$TICKERS', $SHARES, $FILL_PRICES);
EOF
