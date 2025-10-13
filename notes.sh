#!/bin/bash

folder=/home/zaater/doc/notes/
dmenu_theme=/home/zaater/.config/rofi/dmenu.rasi
TERMINAL=alacritty

newnote() {
	name=$(echo "" | rofi -dmenu -theme $dmenu_theme -l 0 -p  'Enter a name ' )
	choice="$name.txt"
	edit
}

edit() {
	setsid -f "$TERMINAL" --class float-term -e nvim $folder$choice
}
selected() {
	choice=$(echo -e "  New\n$(ls -t1 $folder | sed 's/\(.*\)/󰠮  \1/g')" | rofi -dmenu -theme $dmenu_theme -p 'Choose Or Create Note ' | sed 's/.* \(.*\)/\1/g')
	case "$choice" in
		*New) newnote ;;
		*txt) edit ;;
		*) exit 0 ;;
	esac
}

selected
