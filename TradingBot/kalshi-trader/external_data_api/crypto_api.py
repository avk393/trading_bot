import requests
from datetime import datetime, timezone

ts = 1776229497  # your unix timestamp
granularity = 60  # seconds per candle: 60, 300, 900, 3600, 21600, 86400

start = datetime.fromtimestamp(ts, tz=timezone.utc).isoformat()
end   = datetime.fromtimestamp(ts + granularity, tz=timezone.utc).isoformat()

r = requests.get(
    "https://api.exchange.coinbase.com/products/BTC-USD/candles",
    params={"start": start, "end": end, "granularity": granularity},
    headers={"User-Agent": "x"},
)

# Each candle: [time, low, high, open, close, volume]
candles = r.json()
time, low, high, open_, close, volume = candles[0]
print(f"BTC low at {ts}: ${low}")
print(f"BTC high at {ts}: ${high}")
 """
import requests

resp = requests.get("https://api.coinbase.com/v2/prices/BTC-USD/spot")
price = resp.json()["data"]["amount"]
print(f"BTC: ${price}")
"""