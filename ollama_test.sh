 curl https://ollama.com/api/chat \
  -H "Authorization: Bearer $OLLAMA_API_KEY" \
  -d '{
        "model": "qwen3.5:cloud",
        "messages": [
            {
            "role": "user",
            "content": "why is the sky blue?"
            }
        ]
    }'