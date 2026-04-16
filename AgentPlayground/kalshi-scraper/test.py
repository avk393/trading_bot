import requests
import json
from datetime import datetime, timezone, UTC

BASE = "https://api.elections.kalshi.com/trade-api/v2"
series = "KXWTI"
 
def parse_ts(dt_str):
    dt = datetime.fromisoformat(dt_str.replace("Z", "+00:00"))
    return int(dt.timestamp())

def get_events(series_ticker):
    url = f"{BASE}/events"
    params = {
        "series_ticker": series_ticker,
        "limit": 200,
        "status": "settled"
    }
    r = requests.get(url, params=params)
    print(f"get_events status: {r.status_code}")
    return r.json()

def get_markets_for_event(event_ticker):
    url = f"{BASE}/markets"
    params = {
        "event_ticker": event_ticker,
        "limit": 100,
    }
    r = requests.get(url, params=params)
    print(f"get_markets_for_event ({event_ticker}) status: {r.status_code}")
    return r.json()
 
def get_historical_cutoff():
    url = f"{BASE}/historical/cutoff"
    r = requests.get(url)
    return r.json()

def get_candlesticks(ticker, start_ts, end_ts, series_ticker=None):
    # Try live endpoint first (works for markets not yet archived)
    if series_ticker:
        url = f"{BASE}/series/{series_ticker}/markets/{ticker}/candlesticks"
        params = {
            "start_ts": start_ts,
            "end_ts": end_ts,
            "period_interval": 1
        }
        r = requests.get(url, params=params)
        print(f"get_candlesticks ({ticker}) status: {r.status_code}")
        if r.status_code == 200:
            return r.json()
        print("Live endpoint failed, trying historical endpoint...")

    # Fall back to historical endpoint (for archived markets)
    url = f"{BASE}/historical/markets/{ticker}/candlesticks"
    params = {
        "start_ts": start_ts,
        "end_ts": end_ts,
        "period_interval": 1
    }
    r = requests.get(url, params=params)
    print(f"get_candlesticks historical ({ticker}) status: {r.status_code}")
    return r.json()

# retrieve events for the series
events = get_events(series)
# retrieve markets for each event
for event in events.get("events", []):
    market_data = get_markets_for_event(event["event_ticker"])
    # retrieve candlesticks for each market
    for market in market_data.get("markets", []):
        print(f"Market: {market['ticker']} (open: {market['open_time']}, close: {market['close_time']})")
        candles_data = get_candlesticks(market["ticker"],
                                        parse_ts(market["open_time"]),
                                        parse_ts(market["close_time"]),
                                        series_ticker=series)
        print(json.dumps(candles_data, indent=2))

 