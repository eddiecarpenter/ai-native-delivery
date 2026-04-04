#!/bin/bash
# gh-notify.sh — GitHub notification poller for macOS
#
# Polls GitHub notifications every 60 seconds and fires a macOS desktop
# notification for each new unread item. Tracks seen notifications so
# you only get alerted once per event.
#
# Designed to run as a LaunchAgent — see gh-notify.plist for the plist
# and install-gh-notify.sh to install it in one step.
#
# Requirements:
#   - gh CLI authenticated (gh auth login)
#   - macOS (uses osascript for notifications)

GH="${GH_PATH:-/opt/homebrew/bin/gh}"
SEEN_IDS_FILE="$HOME/.gh-notify-seen"
touch "$SEEN_IDS_FILE"

while true; do
  "$GH" api notifications \
    --jq '.[] | select(.unread==true) | .id + "|" + .subject.title + "|" + .subject.type' \
  2>/dev/null \
  | while IFS='|' read -r id title type; do
      if ! grep -qx "$id" "$SEEN_IDS_FILE"; then
        echo "$id" >> "$SEEN_IDS_FILE"
        osascript -e "display notification \"$title\" with title \"GitHub — $type\" sound name \"Ping\""
      fi
  done
  sleep 60
done
