#!/bin/sh
OUT_BASE="~/ollama-logs"
OUT="$OUT_BASE/ollama-$(date +%Y-%m-%d_%H-%M-%S).txt"
echo ollama "$@" >> "$OUT"
set -x
OLLAMA_NOPRUNE=true ollama "$@" | tee "$OUT"
