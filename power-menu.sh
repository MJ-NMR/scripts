#!/bin/bash

#export DISPLAY=:0
#export XAUTHORITY=/run/lightdm/zaater/xauthority


choice=$(printf "Cancel\n  Shutdown\n󰑓  Reboot\n󰒲  Sleep\n  Lock\n󰗽  Logout" | rofi -dmenu -theme /home/zaater/.config/rofi/dmenu.rasi -theme-str 'window { width: 30%; }' -i -p "Power Menu")

case "$choice" in
  *Shutdown) systemctl poweroff ;;
  *Reboot) systemctl reboot ;;
  *Sleep) systemctl suspend && i3lock ;;
  *Lock) i3lock ;;
  *Logout) i3-msg exit ;;
  *) exit 0 ;;
esac

