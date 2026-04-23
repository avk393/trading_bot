# Claude Trading Bot

An autonomous AI trading agent running on Claude Code cloud routines.

## Overview

Five cron jobs fire throughout each weekday. Each firing spins up a fresh Claude Code cloud
container, clones this repo, reads memory, pulls live account state, decides on action, places
orders if warranted, writes new memory, commits back to Git, and sends a ClickUp notification.

**Claude is the bot.** There is no separate process.

## Quick Start (local)

1. Copy `env.template` to `.env` and fill in your credentials.
2. Open this repo in Claude Code.
3. Run `/portfolio` to verify your Alpaca connection.

## Directory Structure

```
├── CLAUDE.md                  # Agent rulebook (auto-loaded every session)
├── env.template               # Template for local .env
├── .gitignore                 # Excludes .env
├── .claude/commands/          # Ad-hoc slash commands for local use
├── routines/                  # Cloud routine prompts (production)
├── scripts/                   # API wrappers
│   ├── alpaca.sh
│   ├── perplexity.sh
│   └── clickup.sh
└── memory/                    # Agent's persistent state (committed to main)
    ├── TRADING-STRATEGY.md
    ├── TRADE-LOG.md
    ├── RESEARCH-LOG.md
    ├── WEEKLY-REVIEW.md
    └── PROJECT-CONTEXT.md
```

## Cloud Routines Schedule (America/Chicago)

| Routine        | Cron          | Time             |
|----------------|---------------|------------------|
| Pre-market     | `0 6 * * 1-5` | 6:00 AM weekdays |
| Market-open    | `30 8 * * 1-5`| 8:30 AM weekdays |
| Midday         | `0 12 * * 1-5`| 12:00 PM weekdays|
| Daily-summary  | `0 15 * * 1-5`| 3:00 PM weekdays |
| Weekly-review  | `0 16 * * 5`  | 4:00 PM Fridays  |

## Setup Prerequisites

- Alpaca brokerage account (paper is fine to start)
- Perplexity API account
- ClickUp account with a Chat channel
- Claude Code cloud routines access
- Claude GitHub App installed on this repo
