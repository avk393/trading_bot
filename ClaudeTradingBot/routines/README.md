# Cloud Routine Prompts

These are the production prompts for Claude Code cloud routines.
Paste each file's content verbatim into its respective routine — do not paraphrase.

## Schedule (America/Chicago)

| File | Cron | Time |
|------|------|------|
| pre-market.md | `0 6 * * 1-5` | 6:00 AM weekdays |
| market-open.md | `30 8 * * 1-5` | 8:30 AM weekdays |
| midday.md | `0 12 * * 1-5` | 12:00 PM weekdays |
| daily-summary.md | `0 15 * * 1-5` | 3:00 PM weekdays |
| weekly-review.md | `0 16 * * 5` | 4:00 PM Fridays only |

## Setup Steps (per routine)

1. Claude Code cloud → Routines → New Routine
2. Name it (e.g. "Trading bot pre-market")
3. Select this repo; branch: main
4. Add all environment variables (see env.template)
5. Toggle ON "Allow unrestricted branch pushes"
6. Set cron schedule and timezone
7. Paste the prompt from the matching file in this directory
8. Save → Run now to test

## Required Environment Variables

```
ALPACA_API_KEY        (required)
ALPACA_SECRET_KEY     (required)
ALPACA_ENDPOINT       (optional; defaults to live trading URL)
ALPACA_DATA_ENDPOINT  (optional; defaults to data URL)
PERPLEXITY_API_KEY    (required for research workflows)
PERPLEXITY_MODEL      (optional; defaults to 'sonar')
CLICKUP_API_KEY       (required for notifications)
CLICKUP_WORKSPACE_ID  (required; numeric)
CLICKUP_CHANNEL_ID    (required; format 4-XXXXXXX-X)
```

**Do NOT create a .env file in the cloud.** Set credentials as env vars on the routine itself.
