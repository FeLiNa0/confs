#!/bin/bash

killall xfce4-notifyd
killall dunst

# Background, foreground, frame color of low, normal, and critical priority messages
dunst \
        -lb "${color12:-#000000}" \
        -lf "${background:-#BBBBBB}" \
        -lfr "${color12:-#000000}" \
        -nb "${background:-#EEEEEE}" \
        -nf "${foreground:-#000000}" \
        -nfr "${background:-#000000}" \
        -cb "${foreground:-#000000}" \
        -cf "${background:-#FFFFFF}" \
        &

notify-send "Dunst is active" "$(date)"
