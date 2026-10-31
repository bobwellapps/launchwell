.pragma library
// SPDX-FileCopyrightText: 2026 bobwellapps
// SPDX-License-Identifier: GPL-2.0-or-later

const version = "1.1.3";

// Turn a QStringList / QVariantList (or anything array-like) into a plain JS array.
function toArray(v) {
    const out = [];
    if (!v) {
        return out;
    }
    for (let i = 0; i < v.length; ++i) {
        out.push(v[i]);
    }
    return out;
}

// Set a property only if this Plasma version has it, so an API change
// can't stop the whole widget from loading.
function setIfExists(obj, prop, value) {
    if (!obj || value === undefined || !(prop in obj)) {
        return false;
    }
    try {
        obj[prop] = value;
        return true;
    } catch (e) {
        console.warn("Launchwell: could not set", prop, e);
        return false;
    }
}

function clamp(v, lo, hi) {
    if (hi < lo) {
        return lo;
    }
    return Math.max(lo, Math.min(hi, v));
}

// Classic Plasma 5 colour category icons bundled in contents/icons/
// (Breeze icons, LGPL-3 - see contents/icons/COPYING-ICONS).
const classicFiles = [
    "applications-all", "applications-development", "applications-education",
    "applications-education-language", "applications-education-mathematics",
    "applications-education-science", "applications-engineering", "applications-games",
    "applications-graphics", "applications-internet", "applications-multimedia",
    "applications-network", "applications-office", "applications-other",
    "applications-science", "applications-system", "applications-utilities",
    "favorites", "folder-recent", "folder-documents", "help-browser", "wine",
    "start-here-kde"
];
const classicAliases = {
    "applications-accessories": "applications-utilities",
    "applications-education-miscellaneous": "applications-education",
    "applications-settings": "applications-system",
    "preferences-system": "applications-system",
    "preferences-desktop": "applications-system",
    "preferences-other": "applications-other",
    "applications-toys": "applications-games",
    "applications-lost-and-found": "applications-other",
    "favorite": "favorites",
    "bookmarks": "favorites",
    "view-history": "folder-recent",
    "document-open-recent": "folder-recent",
    "system-help": "help-browser",
    "help-contents": "help-browser",
    "wine-symbolic": "wine",
    "start-here-kde-plasma": "start-here-kde",
    "start-here": "start-here-kde"
};

// Returns the bundled file name (without .svg) for an icon name, or "".
function classicIcon(name) {
    if (typeof name !== "string" || name.length === 0) {
        return "";
    }
    const base = name.replace(/-symbolic$/, "");
    if (classicFiles.indexOf(base) !== -1) {
        return base;
    }
    return classicAliases[base] || "";
}

// Plain icon name (not a path/URL)?
function isIconName(src) {
    return typeof src === "string" && src.length > 0 && !/[\/:]/.test(src);
}

// Letter used for the A-Z headings: case and accents ignored, numbers -> "#",
// symbols/punctuation -> "&" (same groups Plasma's app list sorts by).
function letterFor(text) {
    let t = String(text || "").trim();
    if (t.length === 0) {
        return "&";
    }
    let c = t.charAt(0);
    if (typeof c.normalize === "function") {
        c = c.normalize("NFD").replace(/[̀-ͯ]/g, "") || c;
    }
    if (/[0-9]/.test(c)) {
        return "#";
    }
    const up = c.toUpperCase();
    if (up === c.toLowerCase()) {
        return "&";                 // not a letter
    }
    return up;
}

// ---- update check
// GitHub "owner/repo" that releases are published to. Empty = never check.
const updateRepo = "bobwellapps/launchwell";

// True when version string a (e.g. "1.2.0" or "v1.2.0") is newer than b.
function isNewer(a, b) {
    const pa = String(a).replace(/^v/i, "").split(/[.-]/).map(n => parseInt(n, 10) || 0);
    const pb = String(b).replace(/^v/i, "").split(/[.-]/).map(n => parseInt(n, 10) || 0);
    for (let i = 0; i < Math.max(pa.length, pb.length); ++i) {
        const x = pa[i] || 0, y = pb[i] || 0;
        if (x !== y) {
            return x > y;
        }
    }
    return false;
}
