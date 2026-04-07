#!/usr/bin/bash
set -eo pipefail
if ! command -v pactl 2>&1 >/dev/null; then
  exit 1
fi

sources="$(pactl list sources short | cut -f2)"
for source in $sources
do
    pactl set-source-volume $source '100%'
done
