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

---

## 2026-04-26 — Pre-market Research (refresh — Sunday PM, for Mon Apr 27 open)

### Infrastructure Warnings
- **PERPLEXITY_API_KEY: MISSING** — fell back to native WebSearch (per protocol)
- **Alpaca API: 403** — account / positions / orders all blocked again. Live state still unavailable. Trading remains BLOCKED.
- **Telegram delivery untested this run** — env vars present but prior session 403'd; will attempt one alert at end.
- Sunday session — cash markets closed; targets Mon 2026-04-27 open.

### Account
- Equity: $10,000.00 (assumed unchanged — live pull blocked; no fills since launch)
- Cash: ~$10,000 (100%)
- Buying power: ~$10,000
- Daytrade count: 0
- Positions: None

### Market Context
- WTI: $94.40 (Fri close, -1.51%); week +13% — biggest weekly gain since early March, driven by Strait of Hormuz / Iran supply-risk premium
- Brent: $105.33 (Fri close, +0.3%); week ~+16%
- S&P 500: Friday close fresh ATH (+0.8%); Nasdaq 100 +1.95% ATH; Intel +22% led semis. Sun-night ES futures not yet quotable
- VIX: 18.71 Fri close (-3.11% on day) — sub-19, two-week low
- This week's catalysts (Apr 27 – May 1):
  - **Wed FOMC** 2:00 ET decision + 2:30 ET Powell presser — stagflation framing in focus (weakening growth + energy-driven inflation)
  - **Wed AMC:** MSFT, GOOGL, META all report; **Thu AMC:** AMZN, AAPL — ~25%+ of index cap reports in 48 hours
  - **Tue:** Apr Consumer Confidence
  - **Wed:** Mar Durable Goods (8:30 ET), housing starts/permits, new home sales
  - **Thu:** Q1 GDP advance, Mar Core PCE, jobless claims (all 8:30 ET)
  - **Fri:** Apr nonfarm payrolls (>200k = sentiment swing)
- Earnings Mon BMO: Verizon (VZ, 7:00 ET release / 8:30 ET call); Mon AMC: Nucor (NUE, est $2.80 EPS / $8.89B rev), Cadence (CDNS)
- Sector momentum YTD 2026: Energy +22% leader (data-center-power thesis); Consumer Staples + Energy at ATHs; Tech mega-cap leadership rotating into "Quality Value"; small/mid-cap leadership expected to expand; Real Estate weak (CRE drag)

### Trade Ideas (watchlist — no entries this session; FOMC week)
1. **NUE (Nucor)** — Mon AMC print; steel/cyclical with sector momentum. Trade only post-print Tue on confirmed beat + green hold above pre-print high. Stop -7% / target +15% (2:1).
2. **XOM** — Energy YTD #1 (+22%); WTI $94 with supply premium intact. Wait for pullback toward 20-day MA; do NOT chase post oil +13% week. Stop -8% / target +16%.
3. **VZ (Verizon)** — Mon BMO print; defensive yield, low-vol — viable only if (a) clean beat, (b) FOMC dovish surprise Wed boosts rate-sensitive yielders. Watch only.

### Risk Factors
- **Critical:** Alpaca IP allowlist still blocks execution
- **FOMC Wednesday** + Powell presser — binary mid-week
- **Mega-cap earnings cluster Wed/Thu** (MSFT/GOOGL/META/AMZN/AAPL) — index whipsaw risk regardless of single-name positioning
- Q1 GDP + Core PCE Thu 8:30 ET — stagflation narrative is live
- NFP Fri — late-week sentiment whip
- Oil +13% wk on Iran/Hormuz risk — geopolitical reversal could unwind energy thesis fast
- Index at ATH after Intel +22% — chase risk elevated; PDT account limits recovery if first trade misfires

### Decision
**HOLD.** Same two-part case as prior entry: (1) Alpaca 403 blocks any execution — infra fix is the only Day-1 priority; (2) even if unblocked, entering ahead of FOMC + 5 mega-cap prints + Q1 GDP/PCE + NFP, with VIX 18.7 and index at ATH, is a textbook chase. No trades. Cash 100%. Watchlist unchanged: NUE post-print Tue, XOM on pullback, small-cap value post-FOMC. Patience > activity.

---

## 2026-04-26 — Pre-market Research (Sunday evening refresh, for Mon Apr 27 open)

### Infrastructure Warnings
- **PERPLEXITY_API_KEY: MISSING** — pre-flight env check; fell back to native WebSearch (per protocol)
- **Alpaca API: 403** — `account` / `positions` / `orders` all returned 403 (IP allowlist unchanged); live state still unavailable. Trading remains BLOCKED.
- **Telegram:** env vars present; will attempt one alert this session for the missing Perplexity key (prior session 403'd).
- Sunday session — cash markets closed; targets Mon 2026-04-27 open.
- Branch note: started on `claude/epic-johnson-uY3Wv`; routine mandates `main`, switched to main and fast-forwarded.

### Account
- Equity: $10,000.00 (assumed unchanged — live pull blocked; no fills since Day 0 launch)
- Cash: ~$10,000 (100%)
- Buying power: ~$10,000
- Daytrade count: 0
- Positions: None

### Market Context
- WTI: $94.7/bbl Fri close (-1.51% on day; week +13% on Iran/Hormuz supply premium)
- Brent: $105.33/bbl Fri close (+0.3% on day; week ~+16%)
- S&P 500: Fri close 7,165.08 (+0.8%) fresh ATH; Nasdaq 24,836.60 (+1.6%) fresh ATH; Intel +23% led tape
- VIX: 18.71 Fri close (-3.11% on day; sub-19, two-week low — benign)
- This week's catalysts (Apr 27 – May 1):
  - **Tue:** FOMC starts; Apr Consumer Confidence
  - **Wed 2:00 ET:** FOMC decision; **2:30 ET** Powell presser (penultimate); Mar Durable Goods, housing starts/permits, new home sales
  - **Wed AMC:** MSFT, GOOGL, META, AMZN report — single-day mega-cap cluster
  - **Thu 8:30 ET:** Q1 GDP advance, Mar Core PCE, jobless claims; **Thu AMC:** AAPL
  - **Thu:** ECB + BOE rate decisions; **Wed evening ET:** BOJ decision
  - **Fri:** Apr nonfarm payrolls
- Earnings Mon BMO: Verizon (VZ, 7:00 ET release / 8:30 ET call; Street est $1.21 EPS / $34.82B rev); Mon AMC: Nucor (NUE, est $2.80 / $8.89B), Cadence (CDNS); also Mon: PSA, AVB, DPZ, UHS, VTR, CINF
- Sector momentum YTD 2026: Energy #1 (+22%, data-center power thesis); Consumer Staples + Energy at ATHs; mega-cap Tech leadership rotating into "Quality Value"; small/mid-cap broadening (S&P 600 Value +10.9% YTD vs S&P 500 +1.8%); Real Estate weak

### Trade Ideas (watchlist only — no entries this session; FOMC + mega-cap week)
1. **NUE (Nucor)** — Mon AMC print; steel/cyclical with sector momentum. Trade only Tue post-print on confirmed beat + clean hold above pre-print high. Stop -7% / target +15% (2:1 R:R).
2. **XOM** — Energy YTD #1; WTI ~$94 supply premium intact. Wait for pullback to 20-day MA — do NOT chase post oil +13% week. Stop -8% / target +16%.
3. **VZ** — Mon BMO defensive yielder; viable only if (a) clean beat AND (b) FOMC dovish surprise Wed boosts rate-sensitive yielders. Watch only.

### Risk Factors
- **Critical:** Alpaca IP allowlist still blocks execution — infra fix is Day-1 priority
- **FOMC Wed** binary mid-week event; stagflation framing live (Q1 GDP + Core PCE Thu)
- **Mega-cap earnings cluster Wed/Thu** — index whipsaw regardless of single-name positioning (>25% of index cap reports in 48h)
- **Triple central bank (ECB/BOE/BOJ)** Thu — global rate cross-currents
- **NFP Fri** — late-week sentiment whip
- Iran/Hormuz oil premium reversible on any de-escalation headline (Trump envoys to Pakistan this weekend)
- Index at ATH after Intel +23% — chase risk elevated; PDT account limits recovery if first trade misfires

### Decision
**HOLD.** Unchanged from prior 2x same-day entries. (1) Alpaca 403 blocks any execution — fix infra before anything else. (2) Even if unblocked: FOMC + 5 mega-cap prints + Q1 GDP/Core PCE + ECB/BOE/BOJ + NFP, with VIX 18.7 and index at ATH = textbook chase setup. No trades. Cash 100%. Watchlist unchanged: NUE post-print Tue, XOM on pullback, small-cap value post-FOMC. Patience > activity.
