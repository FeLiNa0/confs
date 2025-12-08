#!/bin/bash -
ROFI_ARGS="$2"
ROFI_MODE="$1"  # Default -combi, try -recursivebrowser
if command -v rofi > /dev/null
then
    # -normalize-match -- Normalize characters with accents so plain letter matches them, e -> é
    rofi \
      -me-select-entry '' \
      "${ROFI_ARGS:-matching fuzzy}" \
      -show "${ROFI_MODE:-combi}" \
      -fixed-num-lines \
      -eh 2 \
      -modi combi,run,window,ssh,keys \
      -sidebar-mode \
      -lines 50 \
      -normalize-match \
      -max-history-size 5000 -sorting-method fzf
else
    dmenu_run
fi
