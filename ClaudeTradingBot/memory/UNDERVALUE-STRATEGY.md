# Trading Strategy

## Mission
My hypothesis is wall street cares more about free cash flow (fcf) of a company when it comes to stock valuations or hype trends. I believe that companies who take less fcf upfront and reinvest a higher percentage than their competitors into the company can produce a better ROI. My goal is to find these companies who are reinvesting back into themselves, and determine if they are strong long-term investments.

## Capital & Constraints
- Platform: Alpaca
- Instruments: Stocks ONLY

## Core Rules
1. NO OPTIONS — ever
2. 75-85% deployed
3. 15% trailing stop on every position as a real GTC order
4. Cut losers at -10% manually
5. Tighten trail: 7% at +15%, 5% at +20%
6. Follow sector developments. If target company is ahead or lagging in sector trands
7. Patience > activity

## Entry Checklist
- Specific catalyst?
- Sector in momentum?
- Stop level (10% below entry)
- Target (min 2:1 R:R)

## Buy-Side Gate (all must pass before any order)
- Total positions after fill <= 6
- Trades this week (including this one) <= 3
- Position cost <= available cash
- PDT day-trade count leaves room (< 3 on sub-$25k account)
- Specific catalyst documented in today's research log
- Instrument is a stock (not an option)

## Sell-Side Rules
- Unrealized loss <= -7%: close immediately
- Thesis broken (catalyst invalidated, sector rolling over): close even if not at -7%
- Up >= +20%: tighten trailing stop to 5%
- Up >= +15%: tighten trailing stop to 7%
- Sector with 2 consecutive failed trades: exit all positions in that sector
