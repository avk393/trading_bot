#!/usr/bin/env bash
# Telegram notification wrapper. Sends a message to a configured chat.
# Usage: bash scripts/telegram.sh "<message>"

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

: "${TELEGRAM_TOKEN:?TELEGRAM_TOKEN not set in environment}"
: "${CHAT_ID:?CHAT_ID not set in environment}"

MESSAGE="${1:?usage: bash scripts/telegram.sh '<message>'}"

curl -fsS -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${CHAT_ID}" \
  --data-urlencode "text=${MESSAGE}" \
  --data-urlencode "parse_mode=Markdown" \
  > /dev/null

echo

