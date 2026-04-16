"""
fetch_kxwti_candlesticks.py
----------------------------
Fetches ALL historical daily candlesticks for every market
under the KXWTI (WTI Crude Oil) series on Kalshi.

No API key required – all endpoints used are public.

Usage:
  pip install requests
  python fetch_kxwti_candlesticks.py
"""

import requests
import json
import time
from datetime import datetime, timezone

BASE_URL        = "https://api.elections.kalshi.com/trade-api/v2"
SERIES_TICKER   = "KXWTI"
PERIOD_INTERVAL = 1440        # daily candles
OUTPUT_FILE     = "kxwti_candlesticks.json"
REQUEST_DELAY   = 0.4         # seconds between every request

session = requests.Session()
session.headers.update({"Content-Type": "application/json"})


# ── core request helper ───────────────────────────────────────────────────────

def get(path: str, params: dict = None, retries: int = 8) -> dict:
    url = BASE_URL + path
    for attempt in range(retries):
        time.sleep(REQUEST_DELAY)
        try:
            r = session.get(url, params=params, timeout=30)
            if r.status_code == 429:
                wait = 10 * (2 ** attempt)
                print(f"  [429] Rate limited – sleeping {wait}s (attempt {attempt+1}/{retries})…")
                time.sleep(wait)
                continue
            if r.status_code == 503:
                wait = 5 * (2 ** attempt)
                print(f"  [503] Unavailable – sleeping {wait}s…")
                time.sleep(wait)
                continue
            r.raise_for_status()
            return r.json()
        except requests.HTTPError as e:
            print(f"  HTTP {r.status_code} on {path}: {r.text[:200]}")
            raise
        except requests.RequestException as e:
            print(f"  Request error on {path}: {e}")
            if attempt < retries - 1:
                time.sleep(5 * (2 ** attempt))
            else:
                raise
    raise RuntimeError(f"Failed after {retries} retries: {path}")


# ── pagination helpers ────────────────────────────────────────────────────────

def paginate_events(series_ticker: str) -> list:
    events, cursor = [], None
    while True:
        params = {"series_ticker": series_ticker, "limit": 200}
        if cursor:
            params["cursor"] = cursor
        data = get("/events", params)
        batch = data.get("events") or []
        events.extend(batch)
        cursor = data.get("cursor")
        print(f"  Events so far: {len(events)}")
        if not cursor or not batch:
            break
    return events


def paginate_historical_markets() -> list:
    """Page through /historical/markets and return all KXWTI markets."""
    markets, cursor = [], None
    page = 0
    while True:
        page += 1
        params = {"limit": 200}
        if cursor:
            params["cursor"] = cursor
        print(f"  Page {page}…", end=" ", flush=True)
        data = get("/historical/markets", params)
        batch = data.get("markets") or []
        kxwti = [m for m in batch if (m.get("event_ticker") or "").startswith(SERIES_TICKER)]
        markets.extend(kxwti)
        print(f"{len(batch)} records, {len(kxwti)} KXWTI ({len(markets)} total)")
        cursor = data.get("cursor")
        if not cursor or not batch:
            break
        time.sleep(1.5)   # extra pause between pages to avoid 429
    return markets


# ── candlestick fetchers ──────────────────────────────────────────────────────

def fetch_candlesticks_historical(ticker: str, start_ts: int, end_ts: int) -> list:
    candles = []
    chunk = 365 * 24 * 3600
    t = start_ts
    while t < end_ts:
        chunk_end = min(t + chunk, end_ts)
        params = {"start_ts": t, "end_ts": chunk_end, "period_interval": PERIOD_INTERVAL}
        try:
            data = get(f"/historical/markets/{ticker}/candlesticks", params)
            candles.extend(data.get("candlesticks") or [])
        except Exception as e:
            print(f"    Warning: skipping chunk for {ticker}: {e}")
        t = chunk_end
    return candles


def fetch_candlesticks_live(ticker: str, start_ts: int, end_ts: int) -> list:
    params = {"start_ts": start_ts, "end_ts": end_ts, "period_interval": PERIOD_INTERVAL}
    try:
        data = get(f"/series/{SERIES_TICKER}/markets/{ticker}/candlesticks", params)
        return data.get("candlesticks") or []
    except Exception:
        try:
            data = get(f"/historical/markets/{ticker}/candlesticks", params)
            return data.get("candlesticks") or []
        except Exception as e:
            print(f"    Warning: could not fetch candles for {ticker}: {e}")
            return []


# ── timestamp utils ───────────────────────────────────────────────────────────

def parse_ts(dt_str: str, fallback: int) -> int:
    if not dt_str:
        return fallback
    try:
        return int(datetime.fromisoformat(dt_str.replace("Z", "+00:00")).timestamp())
    except Exception:
        return fallback


# ── main ─────────────────────────────────────────────────────────────────────

def main():
    now_ts = int(datetime.now(timezone.utc).timestamp())

    print(f"\n{'='*60}")
    print(f"  Kalshi KXWTI Candlestick Fetcher")
    print(f"  {datetime.now(timezone.utc).isoformat()}")
    print(f"{'='*60}\n")

    # 1. Historical cutoff
    print("► Getting historical cutoff…")
    cutoff_data = get("/historical/cutoff")
    cutoff_ts_str = cutoff_data.get("market_settled_ts", "")
    cutoff_ts = parse_ts(cutoff_ts_str, now_ts - 30 * 24 * 3600)
    print(f"  Cutoff: {cutoff_ts_str} (unix={cutoff_ts})\n")

    # 2. All events
    print(f"► Fetching all events for series {SERIES_TICKER}…")
    events = paginate_events(SERIES_TICKER)
    print(f"  Total events: {len(events)}\n")

    # 3a. Historical markets
    print("► Fetching historical markets (rate-limited)…")
    hist_markets = paginate_historical_markets()
    all_markets = {m["ticker"]: m for m in hist_markets}
    print(f"  Historical markets: {len(all_markets)}\n")

    # 3b. Live markets via events
    print("► Fetching live markets from events…")
    live_count = 0
    cursor = None
    while True:
        params = {"series_ticker": SERIES_TICKER, "with_nested_markets": "true", "limit": 200}
        if cursor:
            params["cursor"] = cursor
        data = get("/events", params)
        for event in data.get("events") or []:
            for m in event.get("markets") or []:
                t = m.get("ticker")
                if t and t not in all_markets:
                    all_markets[t] = m
                    live_count += 1
        cursor = data.get("cursor")
        if not cursor:
            break
    print(f"  Live markets added: {live_count}")
    print(f"  Total unique markets: {len(all_markets)}\n")

    # 4. Candlesticks
    print("► Fetching candlesticks…\n")
    results = []
    tickers = list(all_markets.keys())
    total = len(tickers)
    total_candles = 0

    for i, ticker in enumerate(tickers, 1):
        m = all_markets[ticker]
        fallback_start = cutoff_ts - 30 * 24 * 3600
        start_ts = parse_ts(m.get("open_time") or m.get("close_time"), fallback_start)
        end_ts   = parse_ts(m.get("close_time") or m.get("expiration_time"), now_ts)
        end_ts   = min(end_ts, now_ts)
        if start_ts >= end_ts:
            start_ts = end_ts - 7 * 24 * 3600

        is_hist = bool(m.get("settlement_ts"))
        print(f"  [{i}/{total}] {ticker} {'(hist)' if is_hist else '(live)'}", end=" … ", flush=True)

        candles = fetch_candlesticks_historical(ticker, start_ts, end_ts) if is_hist \
                  else fetch_candlesticks_live(ticker, start_ts, end_ts)

        total_candles += len(candles)
        print(f"{len(candles)} candles")

        results.append({
            "ticker":        ticker,
            "series_ticker": SERIES_TICKER,
            "event_ticker":  m.get("event_ticker"),
            "title":         m.get("title") or m.get("subtitle"),
            "open_time":     m.get("open_time"),
            "close_time":    m.get("close_time"),
            "settlement_ts": m.get("settlement_ts"),
            "result":        m.get("result"),
            "floor_strike":  m.get("floor_strike"),
            "cap_strike":    m.get("cap_strike"),
            "candlesticks":  candles,
        })

    # 5. Save
    output = {
        "series_ticker":           SERIES_TICKER,
        "period_interval_minutes": PERIOD_INTERVAL,
        "fetched_at":              datetime.now(timezone.utc).isoformat(),
        "historical_cutoff_unix":  cutoff_ts,
        "total_markets":           len(results),
        "markets":                 results,
    }

    with open(OUTPUT_FILE, "w") as f:
        json.dump(output, f, indent=2)

    print(f"\n{'='*60}")
    print(f"  Done!")
    print(f"  Markets:       {len(results)}")
    print(f"  Total candles: {total_candles:,}")
    print(f"  Saved to:      {OUTPUT_FILE}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    main()