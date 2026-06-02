#!/bin/bash
CLIENTS=$(mmsg get all-clients 2>/dev/null | jq '.clients')
TAGS=$(mmsg get all-tags 2>/dev/null | jq '.all_tags')

if [ -z "$CLIENTS" ] || [ "$CLIENTS" = "null" ]; then
	echo '{"text": "?", "tooltip": "No data"}'
	exit 0
fi

# Get the focused client
FOCUSED=$(echo "$CLIENTS" | jq '[.[] | select(.is_focused == true)] | .[0]')
if [ "$FOCUSED" = "null" ] || [ -z "$FOCUSED" ]; then
	echo '{"text": "?", "tooltip": "No focused client"}'
	exit 0
fi

FOCUSED_MON=$(echo "$FOCUSED" | jq -r '.monitor')
FOCUSED_TAG=$(echo "$FOCUSED" | jq '.tags[0]')

# Get the layout of the current tag on the focused monitor
LAYOUT=$(echo "$TAGS" | jq -r --arg mon "$FOCUSED_MON" --argjson tag "$FOCUSED_TAG" '
    .[] | select(.monitor == $mon) | .tags[] | select(.index == $tag) | .layout
')

# Only show dots for Monocle (M) or Scroller (S)
if [ "$LAYOUT" != "M" ] && [ "$LAYOUT" != "S" ]; then
	echo '{"text": "", "tooltip": ""}'
	exit 0
fi

# Get all clients on the same monitor and tag, sorted by x position
TAG_CLIENTS=$(echo "$CLIENTS" | jq --arg mon "$FOCUSED_MON" --argjson tag "$FOCUSED_TAG" '
    [.[] | select(.monitor == $mon and (.tags | contains([$tag])) and .is_minimized == false)]
    | sort_by(.x)
')

DOTS=$(echo "$TAG_CLIENTS" | jq -r '
    map(if .is_focused then "●" else "○" end) | join(" ")
')

COUNT=$(echo "$TAG_CLIENTS" | jq 'length')
echo "{\"text\": \"$DOTS\", \"tooltip\": \"$COUNT windows\"}"
