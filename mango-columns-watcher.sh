#!/bin/bash
# Listen to mango events and send signal to waybar on focus/window changes
mmsg watch all-clients | while read -r line; do
    pkill -SIGRTMIN+8 waybar
done
