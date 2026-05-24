#!/bin/bash

#export DISPLAY=:0
#export XAUTHORITY=/run/lightdm/zaater/xauthority

Logout(){
	if [ -n "$NIRI_SOCKET" ]; then
		niri msg action quit --skip-confirmation
	else
		i3-msg exit 
	fi
}

choice=$(printf "Cancel\n \tShutdown\n󰑓 \tReboot\n󰒲 \tSuspend\n󰗽 \tLogout" | rofi -dmenu -theme /home/zaater/.config/rofi/dmenu.rasi -theme-str 'window { width: 30%; }' -i -p "Power Menu")

case "$choice" in
  *Shutdown) systemctl poweroff ;;
  *Reboot) systemctl reboot ;;
  *Suspend) systemctl suspend ;;
  *Logout) Logout;;
  *) exit 0 ;;
esac

