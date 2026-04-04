#!/bin/bash
# install-gh-notify.sh — installs the GitHub notification LaunchAgent
#
# Copies gh-notify.sh to ~/Library/Scripts/, writes the LaunchAgent plist
# to ~/Library/LaunchAgents/, and loads it so notifications start immediately.
# Runs automatically at login from then on.
#
# Usage: bash base/scripts/install-gh-notify.sh
# Uninstall: launchctl unload ~/Library/LaunchAgents/com.user.gh-notify.plist

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/Library/Scripts"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_LABEL="com.user.gh-notify"

mkdir -p "$INSTALL_DIR" "$PLIST_DIR"

# Copy the script.
cp "$SCRIPT_DIR/gh-notify.sh" "$INSTALL_DIR/gh-notify.sh"
chmod +x "$INSTALL_DIR/gh-notify.sh"

# Write the plist with the correct install path substituted.
sed "s|INSTALL_PATH|$INSTALL_DIR|g" "$SCRIPT_DIR/gh-notify.plist" \
  > "$PLIST_DIR/$PLIST_LABEL.plist"

# Unload any existing instance before reloading.
launchctl unload "$PLIST_DIR/$PLIST_LABEL.plist" 2>/dev/null || true
launchctl load "$PLIST_DIR/$PLIST_LABEL.plist"

echo "gh-notify installed and running."
echo "Notifications will fire for unread GitHub events every 60 seconds."
echo "To uninstall: launchctl unload $PLIST_DIR/$PLIST_LABEL.plist"
