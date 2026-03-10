#!/usr/bin/bash
set -eo pipefail
sources="$(pactl list sources short | cut -f2)"
for source in $sources
do
    pactl set-source-volume $source '100%'
done
