#!/usr/bin/env bash
# Remove Launchwell.
set -euo pipefail
kpackagetool6 -t Plasma/Applet -r org.launchwell.launcher
echo "Removed. Restart Plasma with:  systemctl --user restart plasma-plasmashell"
