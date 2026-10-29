#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 bobwellapps
# SPDX-License-Identifier: GPL-2.0-or-later
# Build dist/launchwell-<version>.plasmoid from the package/ folder.
# A .plasmoid is a zip with metadata.json at the top level; Plasma's
# "Install Widget From Local File…" and kpackagetool6 both accept it.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

version=$(python3 -c 'import json;print(json.load(open("package/metadata.json"))["KPlugin"]["Version"])')
code_version=$(sed -n 's/^const version = "\(.*\)";/\1/p' package/contents/ui/tools.js)
if [[ "$version" != "$code_version" ]]; then
    echo "Version mismatch: metadata.json says $version, tools.js says $code_version" >&2
    exit 1
fi

mkdir -p dist
out="dist/launchwell-$version.plasmoid"
rm -f "$out"
(cd package && zip -qr "../$out" metadata.json contents)
echo "Built $out"
