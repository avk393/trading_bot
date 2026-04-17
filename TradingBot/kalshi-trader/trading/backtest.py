"""
Backtest: replay collect_btc_time_trade_signals logic against KXBTC15M_candles.json

Each market item in the JSON contains 15 one-minute candles for a single KXBTC15M
market. This script walks each market, fires the same signal filters used in
bot_agent.py, then evaluates whether the trade would have won.
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime, timezone
from bot_agent import eval_btc_time_trade_signals

sys.path.append(str(Path(__file__).parent.parent / "kalshi_api"))
from get_historical_market_info import (
    parse_ts,
    get_historical_cutoff,
    get_events,
    get_historical_markets_for_event,
    get_recent_markets_for_event,
    get_candlesticks_historical,
    get_candlesticks_recent,
)

def get_market_history(series: str) ->dict:
    # Fetch the cutoff so we know which endpoints to use
    candles_history = []
    cutoff_data = get_historical_cutoff()
    cutoff_raw = cutoff_data.get("market_settled_ts")
    market_settled_cutoff_ts = parse_ts(cutoff_raw) if cutoff_raw else None
    print(f"Historical cutoff (market_settled_ts): {market_settled_cutoff_ts}")

    # Retrieve settled events for the series
    events = get_events(series)
    for event in events.get("events", []):
        event_ticker = event["event_ticker"]

        # Determine if this event's markets are archived or recent
        # Use settlement_time if available, otherwise close_time
        event_time_str = event.get("settlement_time") or event.get("close_time")
        event_ts = parse_ts(event_time_str) if event_time_str else None

        is_historical = (
            event_ts is not None
            and market_settled_cutoff_ts is not None
            and event_ts < market_settled_cutoff_ts
        )

        if is_historical:
            market_data = get_historical_markets_for_event(event_ticker)
        else:
            market_data = get_recent_markets_for_event(event_ticker)

        for market in market_data.get("markets", []):
            ticker = market["ticker"]
            open_ts = parse_ts(market["open_time"])
            close_ts = parse_ts(market["close_time"])
            print(f"Market: {ticker} (open: {market['open_time']}, close: {market['close_time']})")

            # Route candlestick request based on whether the market is archived
            market_close_ts = close_ts
            if (market_settled_cutoff_ts is not None
                    and market_close_ts < market_settled_cutoff_ts):
                candles_data = get_candlesticks_historical(ticker, open_ts, close_ts)
            else:
                candles_data = get_candlesticks_recent(ticker, series, open_ts, close_ts)

            if candles_data.get("error"):
                print(f"  Error: {candles_data['error']}")
                continue

            candles_history.append({
                "ticker": ticker,
                "candlesticks": candles_data.get("candlesticks", []),
            })

    return candles_history

def evaluate_outcome(market: dict, signal: dict) -> dict:
    """
    Determines whether the signal was correct using the final candle close.

    Kalshi markets settle at $1.00 (YES wins) or $0.00 (NO wins).
    We infer settlement from the last candle's close: >= 0.50 → YES, < 0.50 → NO.

    PnL per contract (assuming $1 face value):
        Win:  1.00 - signal_price  (profit = what we collect minus what we paid)
        Loss: -signal_price        (we lose our stake)
    """
    last_price = market["candlesticks"][-1]["price"]
    final_close = float(
        last_price.get("close_dollars")
        or last_price.get("previous_dollars")
        or last_price.get("mean_dollars")
        or last_price.get("open_dollars")
    )
    outcome = "yes" if final_close >= 0.50 else "no"
    won = signal["signal"] == outcome
    pnl = (1.0 - signal["signal_price"]) if won else -signal["signal_price"]

    return {
        **signal,
        "final_close": final_close,
        "outcome": outcome,
        "won": won,
        "pnl_per_contract": round(pnl, 4),
    }


CANDLES_PATH = os.path.join(
    os.path.dirname(__file__), "..", "response", "KXBTC15M_candles.json"
)

def run_backtest(signal_ts, 
                 candles_path, 
                 signal_price_min,
                 signal_price_max) -> list[dict]:
    with open(candles_path) as f:
        candles_history = json.load(f)

    print(f"Loaded {len(candles_history)} markets from {os.path.basename(candles_path)}\n")

    results = []
    skipped_no_signal = 0

    for market in candles_history:
        ticker = market["ticker"]
        candles = market["candlesticks"]
        expiry_ts = candles[-1]["end_period_ts"]

        if not candles:
            continue

        for candle in candles:
            curr_ts = candle["end_period_ts"]
            yes_ask = float(candle["yes_ask"]["low_dollars"])
            no_ask = 1 - float(candle["yes_bid"]["high_dollars"])
            print(
                f"  ticker          : {ticker}\n"
                f"  yes_ask         : {yes_ask}\n"
                f"  no_ask          : {no_ask}\n"
                f"  signal_price_min: {signal_price_min}\n"
                f"  signal_price_max: {signal_price_max}\n"
                f"  expiry_ts       : {expiry_ts}\n"
                f"  signal_ts       : {signal_ts}\n"
                f"  curr_ts         : {curr_ts}\n"
            )


            # Walk candles chronologically; take the first one that fires a signal
            signal = None
            for candle in candles:
                signal = eval_btc_time_trade_signals(ticker, 
                                                     yes_ask,
                                                     no_ask,
                                                     signal_price_min,
                                                     signal_price_max,
                                                     expiry_ts,
                                                     signal_ts,
                                                     curr_ts)
                if signal:
                    signal = signal[0]
                    break

            if not signal:
                skipped_no_signal += 1
                continue

            result = evaluate_outcome(market, signal)
            results.append(result)

        ts_str = datetime.fromtimestamp(
            curr_ts, tz=timezone.utc
        ).strftime("%Y-%m-%d %H:%M UTC")
        status = "WIN " if result["won"] else "LOSS"
        print(
            f"[{result['market_ticker']}]  {ts_str}  "
            f"signal={result['signal']}  price=${result['signal_price']:.2f}  "
            f"final_close=${result['final_close']:.2f}  "
            f"{status}  pnl={result['pnl_per_contract']:+.4f}"
        )
        break


    # --- Summary ---
    print(f"\n{'=' * 60}")
    print(f"Signals fired      : {len(results)}")
    print(f"No signal (filtered): {skipped_no_signal}")

    if not results:
        print("No trades to summarize.")
        return results

    wins = sum(1 for r in results if r["won"])
    losses = len(results) - wins
    total_pnl = sum(r["pnl_per_contract"] for r in results)
    avg_price = sum(r["signal_price"] for r in results) / len(results)
    yes_signals = sum(1 for r in results if r["signal"] == "yes")
    no_signals = len(results) - yes_signals

    print(f"Win / Loss         : {wins} / {losses}  ({wins / len(results) * 100:.1f}% win rate)")
    print(f"Total PnL          : {total_pnl:+.4f} per contract")
    print(f"Avg PnL per trade  : {total_pnl / len(results):+.4f}")
    print(f"Avg signal price   : ${avg_price:.2f}")
    print(f"YES / NO signals   : {yes_signals} / {no_signals}")
    print(f"{'=' * 60}")

    return results


if __name__ == "__main__":
    # Signal filters — must match bot_agent.py
    signal_price_min = 0.75
    signal_price_max = 0.95
    seconds_to_expiry = 300  # fire only in the last 5 minutes of the market
    run_backtest(seconds_to_expiry, CANDLES_PATH, signal_price_min, signal_price_max)
