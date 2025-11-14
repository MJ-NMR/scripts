#!/bin/bash

folder=/home/zaater/doc/notes/
dmenu_theme=/home/zaater/.config/rofi/dmenu.rasi
TERMINAL=alacritty

mkdir -p "$folder"

newnote() {
	name=$(echo "" | rofi -dmenu -theme $dmenu_theme -l 0 -p  'Enter a name ' )
	 if [[ "$name" =~ \.txt$ ]]; then
        choice="$name"
    else
        choice="${name}.txt"
    fi
	edit
}

edit() {
	setsid -f "$TERMINAL" --class float-term -e nvim $folder$choice
}

choice=$(echo -e "  New\n$(ls -t1 $folder | sed 's/\(.*\)/󰠮  \1/g')" | rofi -dmenu -theme $dmenu_theme -p 'Choose Or Create Note ' | sed 's/.* \(.*\)/\1/g')
case "$choice" in
	*New) newnote ;;
	*txt) edit ;;
	*) exit 0 ;;
esac

