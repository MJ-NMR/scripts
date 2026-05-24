#!/usr/bin/env zsh

histfile="$HOME/.cache/cliphist"
placeholder="<NEWLINE>"

highlight() {
	if [ -n "$WAYLAND_DISPLAY" ]; then
		clip=$(wl-paste --primary)
		wl-copy "$clip"
	else
		clip=$(xclip -o -selection primary | xclip -i -f -selection clipboard)
	fi
}

output() {
	if [ -n "$WAYLAND_DISPLAY" ]; then
		clip=$(wl-paste)
	else
		clip=$(xclip -i -f -selection clipboard)
	fi
}

write() {
	[[ -f $histfile ]] || { notify-send "Creating $histfile"; echo -e "clear\n" > $histfile; }
	[[ -z $clip ]] && exit 0

	multiline=$(echo -n "$clip" | sed ':a;N;$!ba;s/\n/'"$placeholder"'/g')
	grep -Fxq "$multiline" "$histfile" || echo  "$multiline" >> "$histfile"

	notification=$(echo \"$multiline\") 
}

sel() {
	selection=$(tac "$histfile" | rofi -dmenu -theme /home/zaater/.config/rofi/dmenu.rasi -b -l 5 -i -p "Clipboard history ")

	if [[ $selection = "clear" ]]; then 
		[[ -f $histfile ]] && rm $histfile 
		notification="Clipboard file cleared"

	elif  [[ -n $selection ]]; then
		echo -n "$selection" | sed "s/$placeholder/\n/g" > /tmp/_clip_tmp
		if [[ -n $WAYLAND_DISPLAY ]]; then
			wl-copy < /tmp/_clip_tmp
		else
			xclip -i -selection clipboard < /tmp/_clip_tmp
		fi
		rm /tmp/_clip_tmp
		notification="Copied to clipboard!"
	else exit 0
	fi
}

case "$1" in
	add) highlight && write ;;
	out) output && write ;;
	sel) sel ;; 
	*)
		printf "%s\n\n" "$0 | File: $histfile"
		printf "add - copy primary to clipboard and add to history\n"
		printf "out - copy stdin to clipboard and add to history\n"
		printf "sel - choose from history/clear\n"
		exit 0
		;;
esac

[[ -z $notification ]] || notify-send -t 1000 -i copy-insync "$notification"

