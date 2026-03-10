#!/bin/bash
DIR="$(todays_work_journal.sh)"
FNAME="$DIR/log_$(date "+%-Y-%m-%d").org"

mkdir -p "$DIR"
exec "$EDITOR" "$FNAME"
