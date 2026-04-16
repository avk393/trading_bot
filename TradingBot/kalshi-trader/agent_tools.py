import os
from dotenv import load_dotenv
import requests
import anthropic
import httplib2  # or just use requests/httpx

load_dotenv()

TELEGRAM_TOKEN = os.getenv("TELEGRAM_TOKEN")
CHAT_ID = os.getenv("CHAT_ID")

tools = [
    {
        "name": "send_telegram_message",
        "description": "Sends a notification message to the user's Telegram account. Use this when a significant event occurs, such as a trade being placed, an error encountered, or a threshold being crossed.",
        "input_schema": {
            "type": "object",
            "properties": {
                "message": {
                    "type": "string",
                    "description": "The message to send to the user."
                }
            },
            "required": ["message"]
        }
    }
]

import requests

def send_telegram_message(message: str) -> str:
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    payload = {"chat_id": CHAT_ID, "text": message}
    resp = requests.post(url, json=payload)
    if not resp.ok:
        print(f"Telegram error {resp.status_code}: {resp.text}")
    resp.raise_for_status()
    return "Message sent successfully."

def handle_tool_call(tool_name: str, tool_input: dict) -> str:
    if tool_name == "send_telegram_message":
        return send_telegram_message(tool_input["message"])
    return "Unknown tool."