#!/bin/bash

switch_xset() {
	if [[ "$status" == "Charging" || "$status" == "Full" ]]; then
		xset s off
		xset -dpms
		notify-send -i battery-good-charging "AC Power" "Chargering"
		return
	else
		[[ "$battery_level" -le 10 ]] && notify-send -u critical -i battery-low "Battery Low" "Battery is at ${battery_level}%!"
		#xset s 1800 1800
		xset s on
		xset +dpms
		xset dpms 0 2700 2700
		notify-send -i battery "AC Power" "Stop Charger"
	fi
}

old=""
while true; do
	battery_level=$(acpi -b | grep -P -o '[0-9]+(?=%)')
	status=$(acpi -b | grep -o 'Charging\|Discharging\|Full')

	echo "status $status old $old"
	if [[ "$status" != "$old" ]]; then
		old=$status
		switch_xset
	fi

	if [[ "$status" == "Discharging" && "$battery_level" -le 10 ]]; then
		notify-send -u critical -i battery-low "Battery Low" "Battery is at ${battery_level}%!" 
		#sleep 400
	fi
	charger=false
	sleep 10
done

