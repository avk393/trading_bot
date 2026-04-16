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

BASE = "https://demo-api.kalshi.co/trade-api/v2"
API_KEY = os.getenv("KALSHI_DEMO_API_KEY")
API_SECRET_PATH = os.getenv("KALSHI_DEMO_API_SECRET_PATH")


def _load_private_key():
    with open(API_SECRET_PATH, "rb") as f:
        return serialization.load_pem_private_key(f.read(), password=None)


def _sign_request(method: str, path: str) -> dict:
    timestamp_ms = str(int(time.time() * 1000))
    message = (timestamp_ms + method.upper() + path).encode("utf-8")

    private_key = _load_private_key()
    signature = private_key.sign(
        message,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.DIGEST_LENGTH,
        ),
        hashes.SHA256(),
    )

    return {
        "KALSHI-ACCESS-KEY": API_KEY,
        "KALSHI-ACCESS-SIGNATURE": base64.b64encode(signature).decode("utf-8"),
        "KALSHI-ACCESS-TIMESTAMP": timestamp_ms
    }



def execute_order(
    ticker: str,
    side: str,          # "yes" or "no"
    action: str,        # "buy" or "sell"
    count: int,         # number of contracts
    yes_price: int = None,  # price in cents (1-99); provide yes_price OR no_price
    no_price: int = None,
    time_in_force: str = "good_till_canceled",  # "fill_or_kill" | "good_till_canceled" | "immediate_or_cancel"
) -> dict:
    """
    Execute an order on a Kalshi market.

    Args:
        ticker:        Market ticker (e.g. "KXWTI-25APR14-T69.99")
        side:          Which side to trade — "yes" or "no"
        action:        "buy" or "sell"
        count:         Number of contracts (whole numbers only)
        yes_price:     Limit price for the Yes side in cents (1–99)
        no_price:      Limit price for the No side in cents (1–99)
        time_in_force: Order duration type (default: "good_till_canceled")

    Returns:
        The created order dict from the API response.
    """
    if side not in ("yes", "no"):
        raise ValueError(f"side must be 'yes' or 'no', got {side!r}")
    if action not in ("buy", "sell"):
        raise ValueError(f"action must be 'buy' or 'sell', got {action!r}")
    if yes_price is not None and no_price is not None:
        raise ValueError("Provide yes_price OR no_price, not both")

    path = "/trade-api/v2/portfolio/orders"
    headers = _sign_request("POST", path)

    body = {
        "ticker": ticker,
        "side": side,
        "action": action,
        "count": count,
        "time_in_force": time_in_force,
    }
    if yes_price is not None:
        body["yes_price"] = yes_price
    if no_price is not None:
        body["no_price"] = no_price

    response = requests.post(f"{BASE}/portfolio/orders", headers=headers, json=body)
    if not response.ok:
        print(f"Error {response.status_code}: {response.text}")
    response.raise_for_status()
    return response.json()["order"]


def get_orders(
    ticker: str,
    status: str = None,   # "resting" | "canceled" | "executed"
    limit: int = None,
    cursor: str = None,
) -> dict:
    """
    Fetch portfolio orders filtered by market ticker.

    Args:
        ticker:  Market ticker to filter by (e.g. "KXWTI-25APR14-T69.99")
        status:  Optional order status filter — "resting", "canceled", or "executed"
        limit:   Max number of orders to return
        cursor:  Pagination cursor from a previous response

    Returns:
        Dict with keys "orders" (list) and "cursor" (str).
    """
    path = "/trade-api/v2/portfolio/orders"
    headers = _sign_request("GET", path)

    params = {"ticker": ticker}
    if status is not None:
        params["status"] = status
    if limit is not None:
        params["limit"] = limit
    if cursor is not None:
        params["cursor"] = cursor

    response = requests.get(f"{BASE}/portfolio/orders", headers=headers, params=params)
    if not response.ok:
        print(f"Error {response.status_code}: {response.text}")
    response.raise_for_status()
    return response.json()


if __name__ == "__main__":
    # Example: buy 1 contract of the Yes side at 45 cents on a given market
    """
    order = execute_trade(
        ticker="KXWTIW-26APR10-T106.00",
        side="yes",
        action="buy",
        count=1,
        yes_price=95,
    )
    print(json.dumps(order, indent=2))
    """

    """ # Example: fetch resting orders for a market
    orders_data = get_orders(ticker="KXWTI-26APR14-T90.99")
    print(json.dumps(orders_data, indent=2))
    if len(orders_data["orders"]) == 0:
        print("Found no order(s) for the market.")
    else:
        print(f"Found {len(orders_data['orders'])} order(s) for the market.") """
