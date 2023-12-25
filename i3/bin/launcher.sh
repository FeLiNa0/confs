#!/bin/bash -
if command -v rofi > /dev/null
then
    # -normalize-match -- Normalize characters with accents so plain letter matches them, e -> é
    rofi \
      -hover-select -me-select-entry '' -me-accept-entry MousePrimary \
      -matching fuzzy \
      -show ${1:-combi} \
      -fixed-num-lines \
      -scroll-method 1 \
      -eh 2 \
      -modi combi,run,window,ssh,keys \
      -sidebar-mode \
      -lines 50 \
      -normalize-match \
      -max-history-size 5000 -sorting-method fzf
else
    dmenu_run
fi
