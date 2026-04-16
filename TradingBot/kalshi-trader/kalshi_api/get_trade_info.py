import requests
import json
import base64
import time
import os
from datetime import datetime, timezone, UTC
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding
from dotenv import load_dotenv

load_dotenv()

BASE = "https://api.elections.kalshi.com/trade-api/v2"
API_KEY = os.getenv("KALSHI_DEMO_API_KEY")
API_SECRET_PATH = os.getenv("KALSHI_DEMO_API_SECRET_PATH")


def _auth_headers(method: str, path: str) -> dict:
    """Build Kalshi RSA-signed auth headers for authenticated endpoints."""
    timestamp_ms = str(int(time.time() * 1000))
    msg = (timestamp_ms + method.upper() + path).encode("utf-8")

    with open(API_SECRET_PATH, "rb") as f:
        private_key = serialization.load_pem_private_key(f.read(), password=None)

    signature = private_key.sign(msg, padding.PKCS1v15(), hashes.SHA256())
    sig_b64 = base64.b64encode(signature).decode("utf-8")

    return {
        "KALSHI-ACCESS-KEY": API_KEY,
        "KALSHI-ACCESS-SIGNATURE": sig_b64,
        "KALSHI-ACCESS-TIMESTAMP": timestamp_ms,
    }


def get_market_trades(ticker: str, limit: int = 100, cursor: str = None) -> dict:
    """
    Fetch recent trades for a specific market.

    Uses GET /markets/trades (public endpoint).

    Args:
        ticker: Market ticker, e.g. "KXBTCD-25APR11-T90000"
        limit:  Number of trades to return (1-1000, default 100)
        cursor: Pagination cursor from a previous response

    Returns:
        Dict with keys:
          - "trades": list of trade objects (trade_id, ticker, count_fp,
                      yes_price_dollars, no_price_dollars, taker_side, created_time)
          - "cursor": pagination cursor (empty string means no more pages)
    """
    params = {"ticker": ticker, "limit": limit}
    if cursor:
        params["cursor"] = cursor

    resp = requests.get(f"{BASE}/markets/trades", params=params)
    resp.raise_for_status()
    return resp.json()


def get_market_orderbook(ticker: str, depth: int = 0) -> dict:
    """
    Fetch the live order book for a specific market.

    Uses GET /markets/{ticker}/orderbook (requires auth).
    Returns yes bids and no bids only — in binary markets a yes bid at price X
    is equivalent to a no ask at (100 - X).

    Args:
        ticker: Market ticker, e.g. "KXBTCD-25APR11-T90000"
        depth:  Number of price levels to return per side (0 = all, 1-100 for
                specific depth)

    Returns:
        Dict with key "orderbook_fp" containing yes/no bid levels with
        fixed-point contract counts.
    """
    path = f"/trade-api/v2/markets/{ticker}/orderbook"
    params = {"depth": depth} if depth > 0 else {}

    resp = requests.get(
        f"{BASE}/markets/{ticker}/orderbook",
        headers=_auth_headers("GET", path),
        params=params,
    )
    resp.raise_for_status()
    return resp.json()


def get_live_market_data(ticker: str, orderbook_depth: int = 10, trade_limit: int = 50) -> dict:
    """
    Convenience wrapper that returns both recent trades and the live order book
    for a market in a single call.

    Args:
        ticker:          Market ticker
        orderbook_depth: Levels of orderbook depth (0 = all)
        trade_limit:     Number of recent trades to fetch

    Returns:
        Dict with keys "trades" and "orderbook".
    """
    trades_data = get_market_trades(ticker, limit=trade_limit)
    orderbook_data = get_market_orderbook(ticker, depth=orderbook_depth)

    return {
        "trades": trades_data.get("trades", []),
        "orderbook": orderbook_data.get("orderbook_fp", {}),
    }

def get_market_data(m_ticker: str) -> dict:
    """
    Fetch metadata for a specific market by its ticker.

    Uses GET /markets/{ticker} (public endpoint, no auth required).

    Args:
        ticker: Market ticker, e.g. "KXWTI-25APR14-T69.99"

    Returns:
        Dict with key "market" containing fields such as:
          ticker, event_ticker, market_type, title, status,
          yes_bid, yes_ask, no_bid, no_ask, last_price,
          volume, open_interest, close_time, expiration_time
    """
    resp = requests.get(f"{BASE}/markets/{m_ticker}")
    resp.raise_for_status()
    return resp.json()


def get_markets_by_event(e_ticker: str) -> dict:
    """
    Fetch all markets within a given event.

    Uses GET /events/{event_ticker}?with_nested_markets=true (public endpoint).

    Args:
        event_ticker: Event ticker, e.g. "KXWTI-26APR13"

    Returns:
        List of market objects associated with the event.
    """
    resp = requests.get(f"{BASE}/events/{e_ticker}",params={"with_nested_markets": "true"})
    resp.raise_for_status()
    return resp.json()


def get_event_by_series(
    series_ticker: str,
    status: str = None,
    with_nested_markets: bool = False,
    limit: int = 200,
    cursor: str = None,
    min_close_ts: int = None,
) -> dict:
    """
    Fetch all events associated with a given series.

    Uses GET /events (public endpoint, no auth required).

    Args:
        series_ticker:       Series ticker, e.g. "KXBTCD"
        status:              Optional filter — 'unopened', 'open', 'closed', or 'settled'
        with_nested_markets: If True, each event includes a 'markets' list
        limit:               Results per page (1-200, default 200)
        cursor:              Pagination cursor from a previous response
        min_close_ts:        Optional filter to only return events with close_time >= this Unix timestamp (in seconds)

    Returns:
        Dict with keys:
          - "events": list of event objects
          - "cursor": pagination cursor (empty string means no more pages)
    """
    params = {
        "series_ticker": series_ticker,
        "limit": limit,
        "with_nested_markets": str(with_nested_markets).lower(),
    }
    if status:
        params["status"] = status
    if cursor:
        params["cursor"] = cursor
    if min_close_ts:
        params["min_close_ts"] = min_close_ts

    resp = requests.get(f"{BASE}/events", params=params)
    resp.raise_for_status()
    return resp.json()


if __name__ == "__main__":
    # Example usage: fetch recent trades and order book for a market
    series = "KXWTI"
    event = "KXWTI-26APR13"
    ticker = "KXWTI-26APR13-T92.99"
    data = get_markets_by_event(event)
    print(json.dumps(data, indent=2))