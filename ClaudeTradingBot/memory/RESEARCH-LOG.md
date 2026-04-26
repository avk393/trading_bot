# Research Log

Daily pre-market research entries will be appended here.
Format each entry:

## YYYY-MM-DD — Pre-market Research

### Account
- Equity: $X
- Cash: $X
- Buying power: $X
- Daytrade count: N

### Market Context
- WTI / Brent:
- S&P 500 futures:
- VIX:
- Today's catalysts:
- Earnings before open:
- Economic calendar:
- Sector momentum:

### Trade Ideas
1. TICKER — catalyst, entry $X, stop $X, target $X, R:R X:1
2. ...

### Risk Factors
- ...

### Decision
TRADE or HOLD (default HOLD if no edge)

---

## 2026-04-24 — Pre-market Research

### Infrastructure Warnings
- **PERPLEXITY_API_KEY: MISSING** — fell back to WebSearch for all research
- **CLICKUP_API_KEY / CLICKUP_WORKSPACE_ID / CLICKUP_CHANNEL_ID: MISSING** — ClickUp notification skipped
- **Alpaca API: 403 host_not_allowed** — IP not in account allowlist; live account state and trading are BLOCKED until resolved

### Account
- Equity: $10,000.00 (Day 0 baseline — live pull blocked by IP allowlist)
- Cash: $10,000.00 (100%)
- Buying power: ~$10,000
- Daytrade count: 0
- Positions: None

### Market Context
- WTI: ~$94–96/bbl (down ~1% on session; US-Iran talks softening oil bid)
- Brent: ~$104–105/bbl (crossed $105 on day, settled ~$104.63)
- S&P 500: Futures +0.4% premarket; cash closed at record high; Nasdaq also record close; ~62% of prediction-market traders leaning "Up" for open
- VIX: ~18.84 (below 19 — two-week low, down 2.4% on session; benign but not complacent territory)
- Today's catalysts:
  - **Intel (INTC) +20%+** best day since 1987 — Q1 beat (EPS $0.29 vs $0.01 est, rev $13.58B vs $12.42B est); agentic AI driving Xeon CPU demand; Google multi-gen commitment; foundry rev +16% YoY
  - Philadelphia Semiconductor Index (SOX) up 18th consecutive day
  - Nvidia retook **$5 trillion** market cap
  - AMD +13% sympathy; ARM +15% sympathy
  - DOJ dropped criminal probe of Fed Chair Powell — removes uncertainty overhang
  - Record-low UMich Consumer Sentiment: **49.8** (lowest since series began 1952)
- Earnings before open: Procter & Gamble (PG), HCA Healthcare (HCA) — plus ~36 others
- Economic calendar: Advance Durable Goods (8:30 ET), UMich Consumer Sentiment Final (10:00 ET, confirmed 49.8), NY Fed Nowcast (12:45 ET)
- Sector momentum YTD: Energy (+525% avg top picks), Technology (+273%), Healthcare (+194%); 6 S&P 500 stocks already +100% YTD — all in AI physical-layer trade (storage, optical networking, chip testing)

### Trade Ideas (watchlist — do NOT chase today's gap-ups)
1. **AMD** — Sympathy play on Intel/agentic AI CPU boom; sector in 18-day momentum streak. Wait for pullback to consolidate post gap-up. Catalyst intact if AI capex narrative holds. Entry: watch for 3–5% pullback from open price; stop 9–10% below entry; target 2:1 R:R minimum.
2. **XOM or CVX** — Energy sector #1 YTD momentum; WTI $94–96 elevated; re-rated as data-center-power hybrid growth. Entry on any intraday pullback toward 20-day MA; stop -8%; target +16%.
3. **SNDK or WDC** — Storage/AI physical-layer; among 6 stocks already +100% YTD; momentum intact but extended — watch only, enter only on clean base breakout, not parabolic chase.

### Risk Factors
- **Critical**: Alpaca IP allowlist blocks all trading — must fix before any execution
- Missing API keys (Perplexity, ClickUp) degrade research and notification workflows
- SOX up 18 straight days — mean reversion risk is elevated; semiconductors crowded
- UMich Sentiment at all-time record low (49.8) — macro deterioration signal despite equity record highs; disconnect is a warning flag
- US-Iran talks softening oil; if deal materializes, Energy sector thesis weakens
- Market at record high on Day 1 — poor risk/reward to chase; PDT rules restrict recovery flexibility if trades go wrong immediately
- Geopolitical wildcard: Middle East situation fluid

### Decision
**HOLD** — Infrastructure blockers prevent trading (Alpaca IP allowlist). Even absent blockers: market at record highs after 18-day semiconductor streak + all-time low consumer sentiment = poor chase setup. No positions. Cash at 100%. Patient start. Watchlist established for AMD, XOM/CVX on pullbacks. Resolve API access issues first.

---

## 2026-04-26 — Pre-market Research (Sunday — for Monday Apr 27 open)

### Infrastructure Warnings
- **PERPLEXITY_API_KEY: MISSING** — wrapper exited 3, fell back to native WebSearch (per protocol)
- **NEON_API_KEY: MISSING** — Neon writes unavailable (not critical for this routine)
- **Alpaca API: 403 (IP allowlist)** — account / positions / orders endpoints all blocked, same as 2026-04-24. Live state could not be pulled. Trading remains BLOCKED until resolved.
- **Telegram API: 403** — alert delivery also blocked (likely same egress IP issue). Notification not delivered this session.
- **Day-of-week note:** today is Sunday; cash markets closed. Research targets Monday 2026-04-27 open.

### Account
- Equity: $10,000.00 (assumed unchanged — live pull blocked; no trades placed since launch)
- Cash: ~$10,000 (100%)
- Buying power: ~$10,000
- Daytrade count: 0
- Positions: None (no fills since Day 0 baseline)

### Market Context
- WTI: ~$94.40 (-1.5%); softer on US-Iran talks (Trump envoys to Pakistan this weekend)
- Brent: ~$105.33 (+0.3%)
- S&P 500: Closed Friday +0.8% at fresh ATH; Nasdaq 100 +1.95% (also ATH); Intel +23% led chips. Sunday-night futures not yet quotable.
- VIX: 18.71 Friday close (sub-19, two-week low — benign)
- Today's catalysts (week of 4/27): FOMC meeting Tue/Wed (Powell's penultimate); mega-cap tech earnings Wed/Thu (MSFT, GOOG, META, AMZN, AAPL); Apr 28 Consumer Confidence; Apr 29 durable orders, housing starts/permits, new home sales
- Earnings Mon BMO: Verizon (VZ, est $1.21/$34.82B), Nucor (NUE), Cincinnati Financial (CINF), Public Storage (PSA), AvalonBay (AVB), Domino's (DPZ), Universal Health (UHS), Ventas (VTR), Cadence (CDNS, AMC)
- Sector momentum YTD 2026: Energy #1, Real Estate strong; Healthcare surprise outperformer; Tech and Financials lagging; small-cap value (S&P 600 Value +10.9% YTD) crushing S&P 500 (+1.8%) — clear cap-down rotation

### Trade Ideas (watchlist — no entries this session)
1. **NUE (Nucor)** — Steel; reports Mon BMO; Industrials/cyclical group has momentum; trade only post-print on confirmed beat + clean reaction. Entry on green hold above pre-print high, stop -7%, target +15% (2:1 R:R).
2. **XOM** — Energy still YTD #1; WTI hovering $94 keeps thesis intact; wait for pullback to 20-day MA. Entry on dip, stop -8%, target +16%.
3. **IWM / S&P 600 Value names** — small-cap value rotation theme; if FOMC delivers dovish surprise Wed, small-caps rip. Watch only — do NOT pre-position into FOMC.

### Risk Factors
- **Critical:** Alpaca IP allowlist still blocks execution — must resolve before any trade
- **FOMC week** (Tue/Wed): pre-position risk is high; binary outcomes mid-week
- **Mega-cap tech earnings** (Wed/Thu): can whipsaw entire indices regardless of single-name positioning
- Market at fresh ATH after Intel +23% — chase risk elevated; semi extension
- Geopolitics: Iran talks fluid; oil thesis vulnerable to a deal headline
- PDT account (<$25k) limits recovery flexibility if early-week trades misfire

### Decision
**HOLD.** Two independent reasons: (1) Alpaca IP allowlist blocks all order routing — infrastructure must be fixed first; (2) even if unblocked, FOMC + 5 mega-cap earnings + ATH after a +23% Intel day = poor entry environment. No trades. Cash 100%. Watchlist: NUE (post-print), XOM (on pullback), small-cap value (post-FOMC). Patience > activity.
