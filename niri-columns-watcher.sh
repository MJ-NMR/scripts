#!/bin/bash

# Listen to niri events and send signal to waybar on focus/window changes
niri msg event-stream | while read -r line; do
	if echo "$line" | rg "focus changed|Window closed|Window opened" -q; then
		pkill -SIGRTMIN+8 waybar
	fi
done
