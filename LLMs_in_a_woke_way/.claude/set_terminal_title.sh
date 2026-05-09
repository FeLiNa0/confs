#!/usr/bin/env bash
input=$(cat)

project=$(projectroot.sh 2>/dev/null)

# Show * when Claude has responded at least once (waiting after a turn),
# or . when the session is fresh (no messages yet).
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  icon="*"
else
  icon="."
fi

work_file="$HOME/.claude/current_work.txt"
work=""
if [ -f "$work_file" ] && [ -s "$work_file" ]; then
  work=" — $(cat "$work_file")"
fi

printf '%s %s%s' "$icon" "$project" "$work"
