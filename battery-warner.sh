#!/bin/bash

sendNotify() {
	if (( st == 1 )); then
		notify-send -i battery-good-charging "AC Power" "Charging"
		return
	else
		notify-send -i battery "AC Power" "Stop Charging"
		(( blevel < 10 )) && notify-send -u critical -i battery-low "Battery Low" "Battery is at ${battery_level}%!"
	fi
}

oldst=0
while true; do
	blevel=$(cat /sys/class/power_supply/BAT0/capacity)
	st=$(cat /sys/class/power_supply/ADP1/online)

	if (( st != oldst )); then
		echo "status $st old $oldst"
		oldst=$st
		sendNotify
	fi
	sleep 10
done

