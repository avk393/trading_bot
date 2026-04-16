import requests
import json
import time
from datetime import datetime, timezone, UTC

BASE = "https://api.elections.kalshi.com/trade-api/v2"
series = "KXBTC15M"

def get_with_retry(url, params=None, max_retries=5):
    """GET request with exponential backoff on 429 rate-limit responses."""
    delay = 1
    for attempt in range(max_retries):
        r = requests.get(url, params=params)
        if r.status_code != 429:
            return r
        retry_after = int(r.headers.get("Retry-After", delay))
        print(f"  Rate limited (429). Waiting {retry_after}s before retry {attempt + 1}/{max_retries}...")
        time.sleep(retry_after)
        delay = min(delay * 2, 60)
    return r

def parse_ts(dt_str):
    dt = datetime.fromisoformat(dt_str.replace("Z", "+00:00"))
    return int(dt.timestamp())

def get_historical_cutoff():
    """Returns market_settled_ts: markets settled before this unix timestamp
    are archived and must be queried via /historical/* endpoints."""
    url = f"{BASE}/historical/cutoff"
    r = get_with_retry(url)
    print(f"get_historical_cutoff status: {r.status_code}")
    return r.json()

def get_events(series_ticker):
    url = f"{BASE}/events"
    params = {
        "series_ticker": series_ticker,
        "limit": 200,
        "status": "settled"
    }
    r = get_with_retry(url, params=params)
    print(f"get_events status: {r.status_code}")
    return r.json()

def get_historical_markets_for_event(event_ticker):
    """Use for events settled before the historical cutoff (archived markets)."""
    url = f"{BASE}/historical/markets"
    params = {
        "event_ticker": event_ticker,
        "limit": 100,
    }
    r = get_with_retry(url, params=params)
    print(f"get_historical_markets_for_event ({event_ticker}) status: {r.status_code}")
    return r.json()

def get_recent_markets_for_event(event_ticker):
    """Use for events settled after the historical cutoff (still in live DB)."""
    url = f"{BASE}/markets"
    params = {
        "event_ticker": event_ticker,
        "status": "settled",
        "limit": 100,
    }
    r = get_with_retry(url, params=params)
    print(f"get_recent_markets_for_event ({event_ticker}) status: {r.status_code}")
    return r.json()

def get_candlesticks_historical(ticker, start_ts, end_ts):
    """Use for markets settled before the historical cutoff."""
    url = f"{BASE}/historical/markets/{ticker}/candlesticks"
    params = {
        "start_ts": start_ts,
        "end_ts": end_ts,
        "period_interval": 1,
    }
    r = get_with_retry(url, params=params)
    print(f"get_candlesticks_historical ({ticker}) status: {r.status_code}")
    return r.json()

def get_candlesticks_recent(ticker, series_ticker, start_ts, end_ts):
    """Use for markets settled after the historical cutoff."""
    url = f"{BASE}/series/{series_ticker}/markets/{ticker}/candlesticks"
    params = {
        "start_ts": start_ts,
        "end_ts": end_ts,
        "period_interval": 1,
    }
    r = get_with_retry(url, params=params)
    print(f"get_candlesticks_recent ({ticker}) status: {r.status_code}")
    return r.json()

if __name__ == "__main__":
    
    # Fetch the cutoff so we know which endpoints to use
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


            print(json.dumps(candles_data, indent=2))
            """
            output_file = f"{series}_candles.json"
            try:
                with open(output_file, "r") as f:
                    existing = json.load(f)
            except (FileNotFoundError, json.JSONDecodeError):
                existing = []
            existing.append(candles_data)
            with open(output_file, "w") as f:
                json.dump(existing, f, indent=2)
            print(f"Candles data appended to {output_file}")
            """
            
            break
        break
