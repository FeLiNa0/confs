#!/bin/sh
# try these models: codellama llama2 mistral mixtral mistral-small3.1 mistral-large
# 2025/07: smollm (135M to 1.7B), deepseek-r1:8b (8B)
# see here for more https://ollama.com/library

# startup command: kitty -e bash -c 'echo -ne "\\033]ollama serve\\007" ; ollama serve' 

#OUT_BASE="$HOME/ollama-logs"

# Configuration
SUB_BASE="ollama-logs/$(date +%Y-%m-%d)"
OUT_BASE="$HOME/Dropbox/sync/technical/$SUB_BASE"
mkdir -p "$OUT_BASE"

# Filename
# Attempt to summarize the arguments in a filename-friendly format
SUMMARY="$(echo "$@" \
  | sed 's/^run \([^ ]*\) \(--\)\+/\1/g' \
  | sed 's/ /_/g' | sed 's/[^[:alnum:] _.-]//g' \
  | cut -c1-32)"
OUT="$OUT_BASE/ollama-$(date +%Y-%m-%d)-${SUMMARY}.txt"

# set -x

# Record total time and print in case of sigint or normal exit
START_TIME="$(date +%s.%N)"
cleanup() {
  # Print total time
  TOTAL_TIME="$(echo "$(date +%s.%N) $START_TIME" | awk '{print ($1 - $2)}' || echo UNKNOWN)"
  echo >> "$OUT"
  echo >> "$OUT"
  echo "#### Total runtime: $TOTAL_TIME sec" | tee --append "$OUT"
}

trap 'echo "Caught SIGINT (Ctrl+C). Cleaning up."; cleanup $!' EXIT

# Print command to file and to stdout
echo ">>>> ollama ""$@"" > $SUB_BASE/$(basename "$OUT")" | tee --append "$OUT"

echo >> "$OUT"
echo >> "$OUT"

# Run ollama
# Also use grep and sed to clear any control characters or shell escape sequences
ollama $@ 2>&1 \
  | grep "[[:print:][:space:]]*" | sed -e "s/\x1b\[.\{1,5\}m//g" \
  | tee --append "$OUT"

# Run final actions
cleanup
