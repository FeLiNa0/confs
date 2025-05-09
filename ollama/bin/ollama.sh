#!/bin/sh
# try these models: codellama llama2 mistral mixtral mistral-small3.1 mistral-large
# see here for more https://ollama.com/library

#OUT_BASE="$HOME/ollama-logs"

# Configuration
OUT_BASE="$HOME/Dropbox/sync/technical/ollama-logs"
OUT="$OUT_BASE/ollama-$(date +%Y-%m-%d_%H-%M-%S).txt"
set -x

# Record total time
START_TIME="$(date +%s.%N)"

# Print command
echo ">>>> ollama $@" >> "$OUT"
echo >> "$OUT"
echo >> "$OUT"

# Run ollama
# Also use grep and sed to clear any control characters or shell escape sequences
OLLAMA_NOPRUNE=true ollama "$@" 2>&1 | \
  grep "[[:print:][:space:]]*" | sed -e "s/\x1b\[.\{1,5\}m//g" | tee --append "$OUT"

# Record total time
TOTAL_TIME="$(echo "$(date +%s.%N) $START_TIME" | awk '{print ($1 - $2)}' || echo UNKNOWN)"

echo >> "$OUT"
echo >> "$OUT"
echo "#### Total runtime: $TOTAL_TIME sec" | tee --append "$OUT"
