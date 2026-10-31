/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

// The "newly installed" symbol shown next to new apps and their category.
// Shape, colour and size come from Appearance settings.
Item {
    id: badge

    property bool active: false
    readonly property var cfg: Plasmoid.configuration
    readonly property bool shown: active && cfg.newAppBadge
    readonly property int shape: cfg.newBadgeShape        // 0 dot, 1 square, 2 diamond, 3 star, 4 "New" label
    readonly property real s: Math.max(4, cfg.newBadgeSize)
    readonly property color tint: cfg.newBadgeColorMode === 1 ? cfg.newBadgeColor : Kirigami.Theme.highlightColor

    visible: shown
    implicitWidth: shown ? (shape === 4 ? newLabel.implicitWidth + s : s) : 0
    implicitHeight: shown ? (shape === 4 ? newLabel.implicitHeight + s * 0.3 : s) : 0
    width: implicitWidth
    height: implicitHeight

    // Dot / square / diamond
    Rectangle {
        anchors.centerIn: parent
        visible: badge.shape <= 2
        width: badge.shape === 2 ? badge.s * 0.75 : badge.s
        height: width
        radius: badge.shape === 0 ? width / 2 : (badge.shape === 1 ? width * 0.15 : 0)
        rotation: badge.shape === 2 ? 45 : 0
        color: badge.tint
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.25)
        antialiasing: true
    }

    // Star
    Text {
        anchors.centerIn: parent
        visible: badge.shape === 3
        text: "★"
        color: badge.tint
        font.pixelSize: badge.s * 1.35
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.25)
    }

    // "New" label
    Rectangle {
        anchors.fill: parent
        visible: badge.shape === 4
        radius: height / 2
        color: badge.tint
        Text {
            id: newLabel
            anchors.centerIn: parent
            text: i18n("New")
            color: (badge.tint.r * 0.299 + badge.tint.g * 0.587 + badge.tint.b * 0.114) > 0.6 ? "black" : "white"
            font.bold: true
            font.pixelSize: Math.max(8, badge.s * 0.9)
        }
    }
}
