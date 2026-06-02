#!/bin/bash

WINDOWS=$(niri msg --json windows 2>/dev/null)

if [ -z "$WINDOWS" ]; then
	echo '{"text": "?", "tooltip": "No data"}'
	exit 0
fi

FOCUSED_WS=$(echo "$WINDOWS" | jq '[.[] | select(.is_focused == true)] | .[0].workspace_id')

WS_WINDOWS=$(echo "$WINDOWS" | jq "[.[] | select(.workspace_id == $FOCUSED_WS)] | sort_by(.layout.pos_in_scrolling_layout[0])")

# Build dot string: filled dot for focused, empty for others
DOTS=$(echo "$WS_WINDOWS" | jq -r '
  map(if .is_focused then "●" else "○" end) | join(" ")
')

echo "{\"text\": \"$DOTS\", \"tooltip\": \"$(echo "$WS_WINDOWS" | jq 'length') windows\"}"
