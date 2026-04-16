# WTI Majority Signal Strategy

## Description
Trade Kalshi WTI crude oil markets using a high-confidence convergence strategy. Enter positions 9-13 hours before market close, follow the majority price signal, and skip any market whose price sits in the uncertain "borderline" zone.

## Core rules

### 1. Market universe
Trade markets only in the `KXWTI` series (WTI crude oil price markets). Each event (e.g. `KXWTI-26APR03`) contains multiple strike markets. Consider every strike as an independent trade.

### 2. Entry timing
Enter between **13 to 9 hours before `close_time`** of each market. Compute `close_time_unix - 46800 <= target_ts <= close_time_unix - 32400`.

### 3. Signal extraction
1. **Call `get_event_by_series()` and use series="KXWTI" and status="open" as parameters** — returns a list of open KXWTI events. 
2. Parse the json response. Extract and store every unique `event_ticker` value from **every single item** in the respone. Do not stop after the first.
3. **For each unique event ticker read in step 2, one-by-one call `get_markets_by_event(e_ticker)` and use the unique `event_ticker` as the `e_ticker` parameter** — returns list of markets for this event. 
4. Parse the json response and extract every unique `ticker` value from **every single item** in the respone. Do not stop after the first.
5. **For each unique `ticker` read in step 4, one-by-one call `get_market_data(m_ticker)` and use the unique `ticker` as the `m_ticker` parameter**— returns data for pricing of this market. 
6. Derive the signal price from the resulting get_market_data() returning dict:
    - Using the response, compare the `market["no_ask_dollars"]` to the `market["yes_ask_dollars"]`
    - If `market["no_ask_dollars"]` > `market["yes_ask_dollars"]`, then `signal_price` = market["no_ask_dollars"] and `signal` = no
    - If `market["no_ask_dollars"]` < `market["yes_ask_dollars"]`, then `signal_price` = market["yes_ask_dollars"] and `signal` = yes
    - Save the corresponding `market_ticker`, `signal_price`, and `signal` together as a group. This information will be needed to execute a trade
Perform the steps in sequential order.
Do not call `get_markets_by_event()` before `get_event_by_series()` — you need the tickers from step 1 as input to step 3.
Do not call `get_market_data()` before `get_event_by_series()` — you need the tickers from step 3 as input to step 5.


### 4. Borderline filter (Hedge 1) — MANDATORY
**If `0.35 ≤ signal_price ≤ 0.65`, SKIP the market entirely. Do not trade it.**
This is the single most important rule. Every historical loss in the baseline occurred inside this band.
**If `signal_price> 0.97`, SKIP the market entirely. Do not trade it.**
If the signal price is too high, it reduces the ROI to below an acceptable threshold.

### 5. Executing trade
- If `0.35 < signal_price < 0.65` and `signal_price < 0.97`, execute trade by calling `execute_trade(ticker, signal, "buy", signal_price)`

### 6. Position sizing
Stake a fixed dollar amount per market (default: $10). Contracts = `stake / entry_price`.

### 7. Exit
Hold to settlement. No intra-position management. Winners pay $1/contract, losers pay $0.

## Required Kalshi API calls. Use following helper functions (call these instead of raw API)
Two pre-built functions are available in `get_trade_info.py` in the same directory. **Always use these rather than calling the API endpoints directly.**

### `get_event_by_series(series_ticker,status = None,with_nested_markets,limit,cursor,min_close_ts,) → dict`
Returns a list of open KXWTI events.
Use this to populate the `event_ticker` loop Rule 2. Replaces the `GET /events` call.

### `get_markets_by_event(ticker: str) → dict`
Takes a event ticker and returns market tickers
Use this to extract the `market_ticker` per Rule 4. Replaces the `GET /events?series_ticker=KXWTI` CALL 

### `get_market_data(m_ticker: str) -> dict`
Takes a market ticker and returns current market pricing
Use this to extract the `signal_price` per Rule 5. Replaces the `GET /events?series_ticker=KXWTI` CALL 
 
### `def execute_trade(ticker,side,action,count,yes_price,no_price,time_in_force,) -> dict:
Uses a market ticker to place a bid. 
Use the `market_ticker`, `signal_price`, and `signal` as the function parameter. Replace the `POST /portfolio/orders` CALL

## Execution pseudocode
```python
STAKE = 10.00
SKIP_LOW, SKIP_HIGH = 0.35, 0.65

for event in get_open_events(series="KXWTI"):
    for market in get_markets(event_ticker=event.ticker):
        target_ts = to_unix(market.close_time) - 11 * 3600
        if now_ts() < target_ts - 60 or now_ts() > target_ts + 60:
            continue  # not the entry window

        candle = get_candlestick(market.ticker, target_ts)
        price = (candle.price.close_dollars
                 or (candle.yes_bid.close_dollars + candle.yes_ask.close_dollars) / 2)
        if price is None:
            continue

        if SKIP_LOW <= price <= SKIP_HIGH:
            log(f"SKIP {market.ticker}: borderline ${price:.2f}")
            continue

        if price > SKIP_HIGH:
            side, entry = "yes", candle.yes_ask.close_dollars
        else:
            side, entry = "no", 1.0 - candle.yes_bid.close_dollars

        count = int(STAKE / entry)
        place_order(market.ticker, side, count, entry)
        log(f"BUY {side} {count}x {market.ticker} @ ${entry:.2f}")
```

## Operational notes for the agent
- **Run frequency:** check every 5 minutes. Each market has a single entry window at T-12h ± 1 minute; missing it means skipping that market for this cycle.
- **Idempotency:** before placing an order, call `GET /portfolio/positions?ticker={ticker}` to confirm no existing position. Never double-enter.
- **Failed fills:** if the limit order at the ask doesn't fill within 30 seconds, cancel and re-price at the current ask. Do not chase more than $0.02 above the original signal price — if the market moved that much, abort this trade.
- **Daily risk cap:** stop entering new trades after 10 positions opened in a single UTC day, regardless of available signals.
- **Known failure modes to monitor:**
  - Shock events where all strikes in one event flip together (MAR11-style). If any two open positions in the same event move >20¢ against you simultaneously, close all positions in that event.
  - Markets with zero volume at T-12h — the signal is unreliable. Require at least 5 total trade candles in the market before entry.

## Configuration
```yaml
series: KXWTI
entry_horizon_hours: 13-9
entry_window_seconds: 60
stake_per_market: 10.00
skip_price_low: 0.35
skip_price_high: 0.65
min_trade_candles: 5
max_daily_positions: 10
order_chase_limit: 0.02
```