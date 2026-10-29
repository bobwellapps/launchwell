#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 bobwellapps
# SPDX-License-Identifier: GPL-2.0-or-later
# Install or update Launchwell straight from this folder (for testing changes).
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
ID="org.launchwell.launcher"

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "kpackagetool6 not found - Launchwell needs KDE Plasma 6." >&2
    exit 1
fi

if kpackagetool6 -t Plasma/Applet -l 2>/dev/null | grep -qx "$ID"; then
    echo "Updating Launchwell..."
    kpackagetool6 -t Plasma/Applet -u package
else
    echo "Installing Launchwell..."
    kpackagetool6 -t Plasma/Applet -i package
fi

echo
read -r -p "Restart Plasma now so the change takes effect? [Y/n] " ans
if [[ ! "${ans:-}" =~ ^[Nn] ]]; then
    systemctl --user restart plasma-plasmashell
    echo "Plasma restarted."
else
    echo "Run this later:  systemctl --user restart plasma-plasmashell"
fi
