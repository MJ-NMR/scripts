#!/bin/env zsh

choice=$(printf "󱌯 EN\n󱌨 AR\n" | rofi -dmenu -theme /home/zaater/.config/rofi/dmenu.rasi -theme-str  'window { width: 30%; } listview { lines: 2; }' -i -p "Language Menu")

case "$choice" in
	*AR*)
		setxkbmap ara
		msg="Arabic"
		;;

	*EN*)
		setxkbmap us
		msg="English"
		;;

	*) exit 0 ;;
esac


notify-send -t 1000 -i copy-insync "Switch to $msg"
