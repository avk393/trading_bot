import requests
import time
import json

BASE_URL = "https://api.elections.kalshi.com/trade-api/v2"
TICKER = "KXBTC15M-26APR150130-30"

# You'll need to implement the RSA-PSS signing logic for auth
timestamp = str(int(time.time() * 1000))

headers = {
    "KALSHI-ACCESS-KEY": "<your-api-key-id>",
    "KALSHI-ACCESS-SIGNATURE": "<computed-rsa-pss-signature>",
    "KALSHI-ACCESS-TIMESTAMP": timestamp,
}

response = requests.get(f"{BASE_URL}/markets/{TICKER}", headers=headers)
#market = response.json()["market"]

# Strike price info
print(json.dumps(response.json(), indent=2))