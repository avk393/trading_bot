import os
from pyexpat.errors import messages
import anthropic
from dotenv import load_dotenv
from agent_tools import tools, handle_tool_call
import kalshi_api.execute_trades
import kalshi_api.get_trade_info

load_dotenv()

ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")

client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)
strategy = open("wti-oil-trading-strategy.md").read()

def run_loop():
    messages = []
    print("***Type 'exit' to quit.***\n")
    while True:
        user_input = input("> ").strip()
        if user_input.lower() in ("exit", "quit"):
            break
        if not user_input:
            continue
        
        messages.append({"role": "user", "content": "send a telegram message saying hello this is a test"})
        response = client.messages.create(
            model="claude-opus-4-5",
            max_tokens=4096,
            tools=tools,
            #system=strategy,
            messages=messages,
        )
        print(f"***Tokens used: {response.usage}***\n")

        messages.append({"role": "assistant", "content": response.content})

        # Print any text blocks
        for block in response.content:
            if block.type == "text":
                print(f"Claude: {block.text}\n")

        # Execute tool calls and collect results
        tool_results = []
        for block in response.content:
            if block.type == "tool_use":
                print(f"[Using tool: {block.name}]")
                result = handle_tool_call(block.name, block.input)
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": str(result),
                })
        messages.append({"role": "user", "content": tool_results})


if __name__ == "__main__":
    run_loop()
