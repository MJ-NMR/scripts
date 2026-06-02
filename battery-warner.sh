#!/bin/bash

BATTERY=$(cat /sys/class/power_supply/BAT0/capacity)
STATUS=$(cat /sys/class/power_supply/ADP1/online)

SOUND_WARN="/usr/share/sounds/alsa/low-batrery-warn.mp3"
SOUND_CRITICAL="/usr/share/sounds/alsa/low-battery-critical.mp3"

if (("$STATUS" != "1")); then
	if ((BATTERY < 5)); then
		notify-send -i battery-low -u critical "Critical Battery" "${BATTERY}% — plug in NOW!"
		paplay "$SOUND_CRITICAL"
	elif ((BATTERY < 15)); then
		notify-send -i battery-low -t 2000 -u normal "Low Battery" "${BATTERY}% remaining"
		paplay "$SOUND_WARN"
	fi
fi
