#!/bin/env bash

choice=$(nsxiv -otb /usr/share/backgrounds/* 2> /dev/null)
[ -n "$choice" ] && feh --bg-fill $choice
