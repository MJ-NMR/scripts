#!/usr/bin/env bash

histfile="$HOME/.cache/cliphist"
placeholder="<NEWLINE>"

highlight() {
	clip=$(xclip -o -selection primary | xclip -i -f -selection clipboard 2>/dev/null) 
}

output() {
	clip=$(xclip -i -f -selection clipboard 2>/dev/null) 
}

write() {
	[ -f "$histfile" ] || { notify-send "Creating $histfile"; echo -e "clear\n" > $histfile; }
	[ -z "$clip" ] && exit 0
	multiline=$(echo -n "$clip" | sed ':a;N;$!ba;s/\n/'"$placeholder"'/g')
	grep -Fxq "$multiline" "$histfile" || echo  "$multiline" >> "$histfile"
	notification=$(echo \"$multiline\") 
}

sel() {
	#selection=$(tac "$histfile" | dmenu -b -l 5 -i -p "Clipboard history:")
	selection=$(tac "$histfile" | rofi -dmenu -theme /home/zaater/.config/rofi/dmenu.rasi -b -l 5 -i -p "Clipboard history ")
	if [ "$selection" = "clear" ]; then 
		clear && notification="Clipboard file cleared"
	elif  [ -n "$selection" ]; then
		if [ "$selection" = "clear" ]; then clear;
		else
			echo -n "$selection" | sed "s/$placeholder/\n/g" | xclip -i -selection clipboard && notification="Copied to clipboard!"
		fi
	fi
}

clear() {
	[ -f "$histfile" ] && rm $histfile 
}

case "$1" in
	add) highlight && write ;;
	out) output && write ;;
	sel) sel ;; 
	cl) clear ;;
	*) 
		printf "%s\n\n" "$0 | File: $histfile"
		printf "add - copy primary to clipboard and add to history\n"
		printf "out - copy stdin to clipboard and add to history\n"
		printf "sel - choose from history\n"
		printf "cl  - clear history file\n"
		exit 0
		;;
esac

[ -z "$notification" ] || notify-send -t 1000 -i copy-insync "$notification"

