import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from kalshi_api.get_trade_info import (
    get_event_by_series,
    get_markets_by_event,
    get_market_data,
)
from kalshi_api.execute_trades import execute_order, get_orders
from agent_tools import send_telegram_message


def collect_wti_trade_signals() -> list[dict]:
    """
    Scans all open KXWTI events, fetches every market under each event,
    prices each market, and returns a list of signal dicts:
        [{"market_ticker": str, "signal": "yes"|"no", "signal_price": float}, ...]
    """
    # Step 1 — fetch all open KXWTI events
    events_response = get_event_by_series(series_ticker="KXWTI", status="open")

    # Step 2 — extract every unique event_ticker
    event_tickers = []
    seen_events = set()
    for event in events_response.get("events", []):
        et = event.get("event_ticker")
        if et and et not in seen_events:
            seen_events.add(et)
            event_tickers.append(et)

    print(f"Found {len(event_tickers)} open event(s): {event_tickers}")

    # Step 3 & 4 — for each event, fetch markets and collect unique market tickers
    market_tickers = []
    seen_markets = set()
    for e_ticker in event_tickers:
        event_data = get_markets_by_event(e_ticker)
        markets = event_data.get("event", {}).get("markets", [])
        for market in markets:
            mt = market.get("ticker")
            if mt and mt not in seen_markets:
                seen_markets.add(mt)
                market_tickers.append(mt)

    print(f"Found {len(market_tickers)} unique market(s).")

    # Step 5 & 6 — for each market ticker, fetch pricing and derive signal
    signals = []
    for m_ticker in market_tickers:
        market_data = get_market_data(m_ticker)
        market = market_data.get("market", {})

        no_ask = market.get("no_ask_dollars")
        yes_ask = market.get("yes_ask_dollars")

        if no_ask is None or yes_ask is None:
            print(f"  [{m_ticker}] Missing ask prices, skipping.")
            continue

        # Skip markets with currently active orders
        orders_data = get_orders(m_ticker)
        if len(orders_data["orders"]) > 0:
            print(f"  [{m_ticker}] Active orders found, skipping.")
            continue

        # Set signals 
        if no_ask > yes_ask:
            signal = "no"
            signal_price = no_ask
        elif yes_ask > no_ask:
            signal = "yes"
            signal_price = yes_ask
        else:
            # Equal prices — no clear edge, skip
            print(f"  [{m_ticker}] Equal ask prices (${no_ask}), skipping.")
            continue

        # Conditions for acceptable signal price (e.g. between $0.65 and $0.95)
        fsignal_price = float(signal_price)
        if fsignal_price < 0.65 or fsignal_price > 0.95:
            print(f"  [{m_ticker}] Signal price ${fsignal_price:.2f} is not in threshold range, skipping.")
            continue

        """
        # Optional: Ensure order is placed within optimal time to maximize ROI (9-13 hours)
        close_time_str = market.get("close_time")
        if close_time_str:
            from datetime import datetime, timezone
            close_dt = datetime.fromisoformat(close_time_str.replace("Z", "+00:00"))
            hours_to_close = (close_dt - datetime.now(timezone.utc)).total_seconds() / 3600
            if not (9 <= hours_to_close <= 13):
                print(f"  [{m_ticker}] {hours_to_close:.1f}h to close (outside 9-13h window), skipping.")
                continue
        else:
            print(f"  [{m_ticker}] Missing close_time, skipping.")
            continue
        """
    
        signals.append({
            "market_ticker": m_ticker,
            "signal": signal,
            "signal_price": fsignal_price,
        })
        print(f"  [{m_ticker}] signal={signal}  signal_price=${fsignal_price:.2f}")

    return signals


def run_trades(count: int = 1, action: str = "buy", signals: list[dict] | None = None) -> list[dict]:
    """
    Collects trade signals and executes an order for each one.

    Args:
        count:   Number of contracts to trade per signal (default: 1)
        action:  "buy" or "sell" (default: "buy")
        signals: Pre-collected signals to use; if None, calls collect_trade_signals()

    Returns:
        List of order dicts returned by the API.
    """
    if signals is None:
        return "No signals provided."
    print(f"\nExecuting {len(signals)} trade(s)...")

    orders = []
    for signal in signals:
        ticker = signal["market_ticker"]
        side = signal["signal"]
        price_cents = round(signal["signal_price"] * 100)

        price_kwargs = {"yes_price": price_cents} if side == "yes" else {"no_price": price_cents}

        print(f"  [{ticker}] {action} {count}x {side} @ {price_cents}¢")
        order = execute_order(ticker=ticker, side=side, action=action, count=count, **price_kwargs)
        orders.append(order)

    return orders


if __name__ == "__main__":
    results = collect_trade_signals()
    print(f"\n=== {len(results)} signal(s) collected ===")
    for s in results:
        print(s)

    print(f"\n=== Executing trades based on signals ===")
    contracts_per_trade = 10
    action = "buy"
    orders = run_trades(contracts_per_trade, action, results)

    # Parse results: store order_id for each successful order keyed by market ticker
    successful_orders = {}
    for order in orders:
        order_id = order.get("order_id")
        ticker = order.get("ticker")
        status = order.get("status")
        if order_id and status not in ("canceled", "rejected"):
            successful_orders[ticker] = order_id
            print(f"  [SUCCESS] {ticker} -> order_id={order_id} (status={status})")
        else:
            print(f"  [FAILED]  {ticker} -> status={status}")

    print(f"\n=== {len(successful_orders)} successful order(s) ===")
    print(successful_orders)

    # Sending Telegram notification with summary of executed trades
    if successful_orders:
        message_lines = [f"Executed {len(successful_orders)} trade(s):"]
        for ticker, order_id in successful_orders.items():
            message_lines.append(f"- {ticker}: order_id={order_id}")
        message = "\n".join(message_lines)
        print("\nSending Telegram notification...")
        send_telegram_message(message)

