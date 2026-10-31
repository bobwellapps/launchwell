/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "tools.js" as Tools

// Invisible grips along the menu's edges: drag to resize the menu.
//
// While dragging, the menu itself doesn't change: an outline (drawn by main.qml
// in a see-through overlay) shows the new size, centred just like the menu will
// be. On release the menu takes that size in one step. Resizing a window live on
// Wayland always flickers when it also has to move, so this avoids it entirely.
//
// The edge against the taskbar has no grip (it stays pinned there).
Item {
    id: handles

    required property var menu      // MenuContent
    required property var lw        // main launcher item
    readonly property var cfg: Plasmoid.configuration

    anchors.fill: parent
    z: 1000
    visible: cfg.dragResize

    readonly property int grip: 6
    readonly property int loc: Plasmoid.location
    readonly property bool sidePanel: loc === PlasmaCore.Types.LeftEdge || loc === PlasmaCore.Types.RightEdge
    // "Next to the panel": the side touching the panel is pinned
    readonly property bool pinned: cfg.verticalPosition === 0
    readonly property bool noTop: pinned && loc === PlasmaCore.Types.TopEdge
    readonly property bool noBottom: pinned && !sidePanel && loc !== PlasmaCore.Types.TopEdge
    readonly property bool noLeft: pinned && loc === PlasmaCore.Types.LeftEdge
    readonly property bool noRight: pinned && loc === PlasmaCore.Types.RightEdge

    // A centred menu grows on both sides, so the dragged edge would move at
    // half speed unless the change is doubled.
    readonly property real hFactor: (!sidePanel && cfg.horizontalPosition <= 1) ? 2 : 1
    readonly property real vFactor: (cfg.verticalPosition === 1 || (pinned && sidePanel)) ? 2 : 1

    readonly property real maxW: Math.max(400, lw.screenRect.width - 2 * cfg.verticalGap)
    readonly property real maxH: Math.max(320, lw.screenRect.height - 2 * cfg.verticalGap)
    readonly property real minW: 360
    readonly property real minH: 300

    property bool dragging: false
    property real newW: 0
    property real newH: 0

    function finish(apply) {
        if (!dragging) {
            return;
        }
        dragging = false;
        lw.hideResizeOutline();
        const w = Math.round(newW), h = Math.round(newH);
        if (apply && (w !== Math.round(menu.width) || h !== Math.round(menu.height))) {
            lw.snapPosition = true;       // jump straight to the new place, no glide
            cfg.menuWidth = w;
            cfg.menuHeight = h;
        }
    }

    component Grip: MouseArea {
        id: g
        property int sx: 0          // -1 left edge, 1 right edge
        property int sy: 0          // -1 top edge, 1 bottom edge
        property point start
        property real startW
        property real startH

        hoverEnabled: true
        preventStealing: true
        cursorShape: (sx !== 0 && sy !== 0) ? (sx === sy ? Qt.SizeFDiagCursor : Qt.SizeBDiagCursor)
                   : sx !== 0 ? Qt.SizeHorCursor : Qt.SizeVerCursor

        onPressed: (m) => {
            start = mapToGlobal(m.x, m.y);
            startW = handles.menu.width;
            startH = handles.menu.height;
            handles.newW = startW;
            handles.newH = startH;
            handles.dragging = true;
            handles.lw.showResizeOutline(startW, startH);
        }
        onPositionChanged: (m) => {
            if (!pressed || !handles.dragging) {
                return;
            }
            const p = mapToGlobal(m.x, m.y);
            if (sx !== 0) {
                handles.newW = Tools.clamp(startW + sx * (p.x - start.x) * handles.hFactor, handles.minW, handles.maxW);
            }
            if (sy !== 0) {
                handles.newH = Tools.clamp(startH + sy * (p.y - start.y) * handles.vFactor, handles.minH, handles.maxH);
            }
            handles.lw.updateResizeOutline(handles.newW, handles.newH);
        }
        onReleased: handles.finish(true)
        onCanceled: handles.finish(false)
    }

    // Escape while dragging cancels
    Keys.onEscapePressed: finish(false)

    // ---- The outline as seen inside the menu (the part the overlay can't show)
    Item {
        anchors.fill: parent
        visible: handles.lw.resizeOutlineShown
        clip: true
        z: -1

        // dim the menu so the outline stands out
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.25)
        }
        Rectangle {
            x: handles.lw.resizeOutlineRect.x - handles.lw.resizeContentOrigin.x
            y: handles.lw.resizeOutlineRect.y - handles.lw.resizeContentOrigin.y
            width: handles.lw.resizeOutlineRect.width
            height: handles.lw.resizeOutlineRect.height
            radius: Kirigami.Units.cornerRadius !== undefined ? Kirigami.Units.cornerRadius : 6
            color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12)
            border.width: 2
            border.color: Kirigami.Theme.highlightColor

            Rectangle {
                anchors.centerIn: parent
                width: sizeText.implicitWidth + Kirigami.Units.gridUnit * 1.5
                height: sizeText.implicitHeight + Kirigami.Units.smallSpacing * 3
                radius: height / 2
                color: Qt.rgba(0, 0, 0, 0.7)
                Text {
                    id: sizeText
                    anchors.centerIn: parent
                    color: "white"
                    font.bold: true
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
                    text: Math.round(handles.newW) + " × " + Math.round(handles.newH)
                }
            }
        }
    }

    // Edges
    Grip { sx: -1; visible: !handles.noLeft;   x: 0; y: handles.grip; width: handles.grip; height: parent.height - 2 * handles.grip }
    Grip { sx: 1;  visible: !handles.noRight;  x: parent.width - handles.grip; y: handles.grip; width: handles.grip; height: parent.height - 2 * handles.grip }
    Grip { sy: -1; visible: !handles.noTop;    x: handles.grip; y: 0; width: parent.width - 2 * handles.grip; height: handles.grip }
    Grip { sy: 1;  visible: !handles.noBottom; x: handles.grip; y: parent.height - handles.grip; width: parent.width - 2 * handles.grip; height: handles.grip }
    // Corners
    Grip { sx: -1; sy: -1; visible: !handles.noLeft && !handles.noTop;     x: 0; y: 0; width: handles.grip * 2; height: handles.grip * 2 }
    Grip { sx: 1;  sy: -1; visible: !handles.noRight && !handles.noTop;    x: parent.width - handles.grip * 2; y: 0; width: handles.grip * 2; height: handles.grip * 2 }
    Grip { sx: -1; sy: 1;  visible: !handles.noLeft && !handles.noBottom;  x: 0; y: parent.height - handles.grip * 2; width: handles.grip * 2; height: handles.grip * 2 }
    Grip { sx: 1;  sy: 1;  visible: !handles.noRight && !handles.noBottom; x: parent.width - handles.grip * 2; y: parent.height - handles.grip * 2; width: handles.grip * 2; height: handles.grip * 2 }
}
