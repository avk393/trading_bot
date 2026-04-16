"""
Claude Agent SDK — Interactive Terminal REPL

Prompts the agent from the terminal and keeps the conversation going
across turns by resuming the same session each time.

Install: pip install claude-agent-sdk
Docs:    https://platform.claude.com/docs/en/agent-sdk.md
"""

import anyio
from claude_agent_sdk import (
    query,
    ClaudeAgentOptions,
    ResultMessage,
    SystemMessage,
    AssistantMessage,
    TextBlock,
    CLINotFoundError,
    CLIConnectionError,
)

# ── Configuration ─────────────────────────────────────────────────────────────

BASE_OPTIONS = ClaudeAgentOptions(
    # Working directory for file operations
    cwd="/Users/ankithkandikonda/Desktop/AgentPlayground/kalshi-scraper",

    # Tools the agent is allowed to use.
    # Options: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch,
    #          AskUserQuestion, Agent
    allowed_tools=["Read", "Glob", "Grep", "WebSearch", "WebFetch"],

    # How permission prompts are handled:
    #   "default"          – prompt before dangerous ops
    #   "acceptEdits"      – auto-accept file edits
    #   "bypassPermissions"– skip all prompts (use with caution)
    permission_mode="default",

    # Optional: custom system prompt
    # system_prompt="You are an expert Python developer. Be concise.",

    # Optional: cap the number of agent turns per message
    # max_turns=20,

    # Optional: model override (defaults to whatever the CLI is configured for)
    # model="claude-opus-4-6",
)

# ── Helpers ───────────────────────────────────────────────────────────────────

async def run_turn(prompt: str, session_id: str | None) -> str | None:
    """Send one prompt to the agent, stream the response, return the session ID."""
    options = BASE_OPTIONS
    if session_id:
        # Resume the existing session so the agent retains full context
        options = ClaudeAgentOptions(**{**BASE_OPTIONS.__dict__, "resume": session_id})

    captured_session_id = session_id

    async for message in query(prompt=prompt, options=options):
        if isinstance(message, SystemMessage) and message.subtype == "init":
            captured_session_id = message.data.get("session_id")

        elif isinstance(message, AssistantMessage):
            for block in message.content:
                if isinstance(block, TextBlock):
                    print(block.text, end="", flush=True)

        elif isinstance(message, ResultMessage):
            print()  # newline after streamed response

    return captured_session_id

# ── Main REPL ─────────────────────────────────────────────────────────────────

async def main() -> None:
    session_id: str | None = None
    print("Claude Agent  |  type 'exit' or press Ctrl-C to quit\n")

    try:
        while True:
            try:
                prompt = input("> ").strip()
            except EOFError:
                break

            if not prompt:
                continue
            if prompt.lower() in {"exit", "quit", "q"}:
                break

            print("\nClaude: ", end="", flush=True)
            session_id = await run_turn(prompt, session_id)
            print()

    except CLINotFoundError:
        print("Claude Code CLI not found.\nInstall: pip install claude-agent-sdk")
    except CLIConnectionError as e:
        print(f"Connection error: {e}")
    except KeyboardInterrupt:
        pass

    print("Bye.")


if __name__ == "__main__":
    anyio.run(main)
