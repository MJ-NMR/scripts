#!/usr/bin/env bash

#credit: https://github.com/theopn/haunted-tiles/blob/main/scripts/rofi-dunst-manager.sh

function replace_special_char() {
  # replace & < > since Rofi throws Pango error with them
  echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

function get_notif_list() {
  local uptime=$(awk '{print $1}' /proc/uptime)

  echo "$HIST_JSON" | jq -r --arg uptime "$uptime" '
  .data[0][] |
    (($uptime | tonumber) - (.timestamp.data / 1000000)) as $age |
    (
      if $age < 60 then "\($age | floor)s"
      elif $age < 3600 then "\($age / 60 | floor)m"
      elif $age < 86400 then "\($age / 3600 | floor)h"
      else "\($age / 86400 | floor)d"
      end
    )
    as $time |
      "<span size=\"small\">[\($time)]</span> <b>\(.appname.data | @html)</b>: \(.summary.data | gsub("\n"; " ") | @html)"
  '
}

function set_shell_var() {
  echo "$HIST_JSON" | jq -r --argjson idx "$1" '
  .data[0][$idx] |
    "ID=\(.id.data) APP=\(.appname.data | @sh) SUMMARY=\(.summary.data | @sh) BODY=\(.body.data | @sh) URGENCY=\(.urgency.data | @sh)"
  '
}


##### main execution #####

if ! pgrep -x "dunst" > /dev/null && ! pgrep -x ".dunst-wrapped" > /dev/null; then
  # -modi run to prevent loading other plugins
  rofi -modi run -e 'Dunst not running :(' \
  exit 1
fi

while true; do
  HIST_JSON=$(dunstctl history)

  # -format i to return index as an output instead of str
  # -i for case insensitivity
  idx=$(get_notif_list | rofi -dmenu -p "History" -markup-rows -format i -i)
  # Exit if no selection
  [[ -z "$idx" ]] && exit 0

  # set variables with jq
  eval $(set_shell_var "$idx")

  msg="<b>App:</b> $(replace_special_char "$APP")
<b>ID:</b> "$ID" | <b>Urgency:</b> "$URGENCY"
<b>Summary:</b> $(replace_special_char "$SUMMARY")
$(replace_special_char "$BODY")
  "
  action=$(echo -e "delete\ndisplay\nback" | rofi -dmenu -p ">" \
    -mesg "$msg" \
    -markup-rows \
    -theme-str 'mainbox {children: [ "message", "listview" ];}' \
    -theme-str 'listview {columns: 3; lines: 1;}'               \
)

  if [[ -z "$action" ]]; then
    exit 0
  elif [[ "$action" == "delete" ]]; then
    dunstctl history-rm "$ID"
  elif [[ "$action" == "display" ]]; then
    dunstctl history-pop "$ID"
  fi

done
