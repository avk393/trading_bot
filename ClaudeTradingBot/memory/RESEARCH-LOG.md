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

---

## 2026-04-28 — Pre-market Research (Tuesday evening refresh, for Wed Apr 29 open)

### Infrastructure
- Perplexity: OK (rc=0 on 7 queries; PERPLEXITY_API_KEY restored to .env this session).
- Alpaca: OK (account/positions/orders all 200; prior 403 IP-allowlist block has cleared).
- Branch: main; will commit + push at Step 6.

### Account (live pull, 22:57 CDT)
- Equity: $100,000.00 (paper)
- Cash: $100,000.00
- Buying power: $200,000 (margin x2)
- Daytrade count: 0; PDT flag: false
- Positions: none; Open orders: none
- Note: TRADING-STRATEGY.md caps deployable capital at ~$10,000 — strategy file overrides paper account size for sizing/risk.

### Market Context
- WTI: ~$94 spot per intraday note; June WTI futures (CLM26) +3.69% on Apr 28 — energy bid persists. Geopolitical premium still embedded.
- Brent: $109.96 (Apr 28, 9:00 ET) per Fortune; up from $106.73 prior session.
- S&P 500 cash: 7,173.93 (+0.1%) Apr 28 close, 3 of 11 sectors green; new ATH region intact.
- ES futures (premarket Apr 29): ~6,657.50 (+0.10%) per Business Insider feed — note: figure inconsistent with cash 7,173.93, treat as low confidence; Nasdaq fut +0.07%, YM +0.12%.
- VIX: 18.36 close Apr 28 (open 18.30) — sub-19, benign regime.
- Sector momentum YTD: Energy +38.3% (#1, 6-mo +40.4%, 12-mo +37.8%); Real Estate +2.8% #2 distant; Tech leading April monthly (+2.2%) on SOX 18-day +44% streak (longest in 32 yrs); Tech most-extended vs 200-DMA since 2000.

### This Week's Catalysts
- **Wed Apr 29 (today/tomorrow open):** FOMC rate decision + Powell presser (2:00/2:30 ET); Core PCE m/m, Employment Cost Index q/q, Unemployment Claims (8:30 ET); Mar Durable Goods.
- **Wed AMC:** MSFT, GOOGL, META.
- **Thu Apr 30:** Advance Q1 GDP, GDP price index, Core PCE m/m, Jobless Claims (8:30 ET); **Thu AMC:** AMZN, AAPL.
- **Fri May 1:** No top-tier US macro on this calendar pull (NFP not scheduled this week per Perplexity; verify against BLS if material).
- BMO Wed Apr 29 earnings: Camden National (CAC) confirmed; full BMO list incomplete in Perplexity result — accept as a known gap.

### Trade Ideas (watchlist; FOMC + mega-cap night = no entries)
1. **NUE (Nucor)** — Mon AMC print already passed; if post-print action confirmed beat + held above pre-print high, eligible. Need confirmation before any entry. Stop -7% / target +15% (2:1).
2. **XOM** — Energy YTD +38.3% leader; do NOT chase. Wait for pullback to 20-DMA. Stop -8% / target +16%.
3. **Semis (SOX) caution short** — N/A as long-only; flagging that SOX +44% in 18 sessions and Tech most-extended vs 200-DMA since 2000 is a chase-warning, not an entry. Avoid late Tech entries today.

### Risk Factors
- **FOMC today (Apr 29) 2:00 ET** — binary.
- **Mega-cap earnings cluster Wed/Thu AMC** (MSFT, GOOGL, META, then AMZN, AAPL) — index whipsaw risk.
- **Q1 GDP advance + Core PCE Thu 8:30 ET** — stagflation tape risk.
- Energy sector +38.3% YTD with WTI/Brent bid: reversal headline (de-escalation) could unwind fast.
- SOX/Tech 200-DMA stretch most extreme since 2000 — chase risk in semis.
- Premarket ES quote (6,657.50) is suspect vs cash 7,173.93 — treat that single number as low confidence; rely on cash + sector tape.

### Decision
**HOLD.** Cash 100%. No entries ahead of FOMC (today/Wed) + 5 mega-cap prints over 48h + Q1 GDP/Core PCE Thu, with VIX 18.4 and index in ATH zone. Watchlist: NUE only after confirmed post-print follow-through; XOM only on a real pullback (not at 38% YTD top); no Tech chase. Patience > activity.

---

## 2026-04-28 — Pre-market Research (cron 23:17 CDT)

### Infrastructure
- Run: cron pre-market.sh; log /Users/thekithlord/trading_bot/ClaudeTradingBot/logs/pre-market-2026-04-28.log
- Perplexity: 7/7 queries ok.
- Alpaca: account/positions/orders 200 OK.
- Branch: main.

### Account (live pull, 23:17 CDT)
- Equity: $100000
- Cash: $100000
- Buying power: $200000
- Daytrade count: 0; PDT flag: False
- Positions: 0; Open orders: 0
- Note: TRADING-STRATEGY.md caps deployable capital at ~$10,000.

### Market Context — Oil
As of April 28, 2026, **Brent crude oil was trading at $109.96 per barrel**[1], while specific WTI pricing data from that date is limited in the search results. However, a forecast indicated **WTI was testing the $100 level** on April 29, 2026[3], and technical analysis from April 28 suggested WTI was trading around $94 with expectations to reach $99[7].

The prices reflect elevated levels driven by geopolitical tensions—crude prices have climbed as stalled peace talks between the US and Iran are keeping the Strait of Hormuz closed, tightening global oil supplies[8].

### Market Context — S&P 500 Futures (premarket)
**S&P 500 futures (June 2026 E-mini contract) traded at 6,657.50 in premarket on April 28, 2026, up 6.50 points or 0.10% as of 06:22 AM.** [1]

This reflects the close of premarket trading for April 28, with the contract showing a +11.90% gain since March 27, 2026, reaching intraday levels around that date.[3] Broader context includes mixed futures after S&P 500 and Nasdaq record highs on April 27, alongside a -0.63% drop in June E-mini S&P futures amid a -0.66% decline in the spot S&P 500 Index.[3][4] Prediction markets on Robinhood priced the April 28 settlement around 7125 (93¢ probability above that level), indicating forward expectations near 7000-7300.[2] Real-time data from sources like Investing.com confirms ongoing E-mini S&P 500 futures coverage, though specific intraday premarket quotes vary by platform.[5]

### Market Context — VIX
The **VIX closed at 18.36** on April 28, 2026, with an opening of 18.30[3]. The spot price was recorded at $18.25, representing a 1.28% increase from the previous close of 18.02[1].

### Today's Catalysts
**Top stock market catalysts on April 28, 2026, centered on the semiconductor sector's record rally driven by AI themes and geopolitics, alongside standout individual stock performances.** [1][2]

### Semiconductor Sector Surge
The **Philadelphia Semiconductor Index (SOX)** achieved an 18-day winning streak ending April 28, its longest in 32 years, with a 44% rise since March 31, fueled by investor chasing of the **AI theme** and geopolitical factors.[1] Global semiconductor spending projections reached $1.3 trillion for 2026, up 64% year-over-year, supporting fundamentals amid overbought conditions (SOX most extended vs. 200-day moving average since 2000).[1] Chipmakers propelled broader tech gains, making **technology the only overbought S&P 500 sector**.[1]

### Top-Performing Stocks
April 2026 monthly gainers highlighted extreme momentum in select names:
- **MGRT (+1,033%)**, **ONEG (+311%)**, **XNDU (+269%)**, **ROLR (+202%)**, **MXL (+194%)**.[2]

### Stocks to Watch
- **Growth stocks**: Ascendis Pharma (ASND), Teledyne Technologies (TDY), Prologis (PLD), Hamilton Lane (HLNE), Elmet Group (ELMT).[3]
- **Value stocks** (high volume): Invesco QQQ (QQQ), Sandisk (SNDK), Intel (INTC), CoreWeave (CRWV), ProShares UltraPro Short QQQ (SQQQ), Bloom Energy (BE), Nebius Group (NBIS).[4]

### Other Mentions
Tesla (TSLA) approached key support at $342.95, with potential rally targets at $398.25 if closing near $378.55.[5] Broader context included Bitcoin and Big Tech rallies amid ceasefire uncertainty.[4]

### Earnings Before Open
**No US companies are scheduled to report earnings before market open on April 28, 2026, based on available calendars.** [1][2][6]

CapyFin's earnings calendar for 2026-04-28 lists zero announcements before open, after close, or overall for that day. [1] Stock Analysis confirms 195 earnings on April 28 (Tuesday) but 247 on April 29 (Wednesday), with examples like Verizon (VZ) on April 27 before open and Tradeweb Markets (TW) explicitly before open—none specified for April 28 BMO. [2] MarketChameleon defines BMO as "before market open" but provides no April 28 BMO entries in the results. [6]

International reports occur on April 28 (e.g., Boliden AB, ASSA ABLOY AB at 12:00 AM UTC), but these are not US BMO and may not align with US market open (9:30 AM ET). [3] Other calendars like Business Insider and Wall Street Horizon lack specific April 28 BMO details. [4][7]

Data is preliminary; confirm via official sources like company IR pages, as dates can shift. [7]

### Economic Calendar
Based on the economic calendar for the week of April 28-30, 2026, the following key releases are scheduled:

**Tuesday, April 28:**
- **BOJ Interest Rate Decision** and Core CPI (Japan)[2]
- **CB Consumer Confidence** (USD)[1]
- **Richmond Manufacturing Index** (USD)[1]
- **German Prelim GDP q/q** (EUR)[1]

**Wednesday, April 29:**
- **Interest Rate Decisions** for USD and CAD[1]
- **German Prelim CPI m/m** (EUR)[1]

**Thursday, April 30:**
- **Interest Rate Decisions** for GBP and EUR[1]
- **Core CPI Flash Estimate y/y and CPI Flash Estimate y/y** (EUR)[1]
- **Advance GDP q/q and Advance GDP Price Index q/q** (USD)[1]
- **Core PCE Price Index m/m, Employment Cost Index q/q, and Unemployment Claims** (USD)[1]

The week features critical **inflation data** (CPI, PCE, PPI) and **multiple central bank interest rate decisions** across major currencies, along with employment metrics and GDP figures. These releases are typically high-impact events for currency and financial markets[1][5].

### Sector Momentum
**No direct YTD performance data for S&P 500 sectors as of April 28, 2026, is available in the provided search results.[1][2][4][5][6]**

Recent market flows indicate **health care** saw demand while **macro, energy, and communication services** faced supply as of April 28, 2026, suggesting relative momentum weakness in those sectors.[1]

The Invesco S&P 500 Momentum ETF (SPMO), tracking the 100 S&P 500 stocks with strongest volatility-adjusted momentum, had top sector weights of **Technology (35.24%)**, **Financial Services (19.89%)**, and **Communication Services (14.51%)**.[2]

S&P 500 closed at 7,174 on April 28, 2026, amid narrow breadth reliant on mega-cap tech and semis.[1]

**Limitations**: Search results lack explicit YTD sector returns (e.g., no percentages from Jan 1 to Apr 28, 2026); sector tracker tools [5] and relative performance charts [4] provide general methods but no specific 2026 data. Flows and ETF weights offer indirect momentum signals.[1][2]

### Trade Ideas
- Watchlist only by default; this is an automated routine. Manual review required before any entry.

### Risk Factors
- Per TRADING-STRATEGY.md: 75-85% deployed (currently 0 positions); max 6 names; max 3 new trades / week.
- Mega-cap and macro events: see Today's Catalysts and Economic Calendar above.

### Decision
**HOLD by default.** Cash 100%. Automated routine does not enter positions; manual review required. Patience > activity.
