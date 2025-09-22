#!/bin/bash

bdown () {
	c=$(brightnessctl get)
	if (( $c > 3840 )); then
		brightnessctl set 20%-;
	fi
}
case "$1" in
    up) brightnessctl set 20%+;;
	down) bdown ;;
esac
