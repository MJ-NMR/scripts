#!/bin/bash
case "$1" in
    up)
        pamixer -i 5
        volume=$(pamixer --get-volume)
        notify-send "Volume Up" "${volume}%" -t 200
        ;;
    down)
        pamixer -d 5
        volume=$(pamixer --get-volume)
        notify-send "Volume Down" "${volume}%" -t 200
        ;;
    mute)
        pamixer -t
        status=$(pamixer --get-mute)
        if [ "$status" = "true" ]; then
            notify-send "Volume" "Muted"
        else
            notify-send "Volume" "Unmuted"
        fi
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        exit 1
        ;;
esac
