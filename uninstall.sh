#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 bobwellapps
# SPDX-License-Identifier: GPL-2.0-or-later
# Remove Launchwell.
set -euo pipefail
kpackagetool6 -t Plasma/Applet -r org.launchwell.launcher
echo "Removed. Restart Plasma with:  systemctl --user restart plasma-plasmashell"
