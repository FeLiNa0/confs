#!/bin/sh
if ! command -v nvidia-smi >/dev/null 2>&1 ; then
    echo "WARNING: Are NVidia drivers installed?"
fi

if ! command -v ollama >/dev/null 2>&1 ; then
    echo "ERROR: ollama not installed"
fi

for model in codellama llama2 mistral; do
    ollama pull $model
    notify-send "Model $model downloaded"
done
