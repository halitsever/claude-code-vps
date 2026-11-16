#!/usr/bin/env bash
# Pushes Claude's "waiting for you" notices to the phone via ntfy.
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude seni bekliyor"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
