#!/usr/bin/env bash

copy() {
	if [ -n "$WAYLAND_DISPLAY" ]; then
		selection="$(wl-paste --primary --no-newline | sed -z 's/^[[:space:]]*//;s/[[:space:]]*$//')"
		wl-copy --trim-newline <<<$selection
	else
		selection=$(xclip -o -selection primary | sed -z 's/^[[:space:]]*//;s/[[:space:]]*$//' | xclip -i -f -selection clipboard)
	fi
	# cliphist store <<<$selection
	notify-send -t 1000 -i copy -- "Copy" "$selection"
}

sel() {
	selection="$(cliphist list | rofi -dmenu)"
	if [[ $selection == "" ]]; then
		exit 0
	fi
	if [[ $selection == "clear" ]]; then
		cliphist clear
		notify-send -t 1000 -i delete "cliphist db cleared"
		exit 0
	fi
	decoded="$(cliphist decode <<<$selection)"
	if [ -n "$WAYLAND_DISPLAY" ]; then
		wl-copy --trim-newline <<<$decoded
	else
		xclip -selection clipboard <<<$decoded
	fi
	notify-send -i copy -- "Copy" "$decoded"
}

case "$1" in
copy) copy ;;
sel) sel ;;
*)
	sel
	printf "%s\n\n" "$0 | File: $histfile"
	printf "copy - copy selection to clipboard and add to history\n"
	printf "sel - choose from history/clear\n"
	exit 0
	;;
esac
