#!/bin/bash

paused=$(dunstctl is-paused)
count=$(dunstctl count waiting)

if [ "$paused" = "true" ]; then
	if [ "$count" -gt 0 ]; then
		echo '{"text": "", "class": "dnd-notification", "alt": "dnd-notification"}'
	else
		echo '{"text": "", "class": "dnd-none", "alt": "dnd-none"}'
	fi
else
	if [ "$count" -gt 0 ]; then
		echo '{"text": "", "class": "notification", "alt": "notification"}'
	else
		echo '{"text": "", "class": "none", "alt": "none"}'
	fi
fi
