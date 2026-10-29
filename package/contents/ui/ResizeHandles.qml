/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "tools.js" as Tools

// Invisible grips along the menu's edges: drag to resize the menu.
// The edge against the taskbar has no grip (it stays pinned there).
// The size is shown live while dragging and saved on release.
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

    // A centred menu grows on both sides, so the dragged edge moves at
    // half speed unless we double the change.
    readonly property real hFactor: (!sidePanel && cfg.horizontalPosition <= 1) ? 2 : 1
    readonly property real vFactor: (cfg.verticalPosition === 1 || (pinned && sidePanel)) ? 2 : 1

    readonly property real maxW: Math.max(400, lw.screenRect.width - 2 * cfg.verticalGap)
    readonly property real maxH: Math.max(320, lw.screenRect.height - 2 * cfg.verticalGap)

    // KWin does the resizing (smooth, one step per frame) when it can; the
    // hand-made fallback below is only used if the system refuses.
    property bool systemResizing: false
    property bool sawSizeChange: false

    Connections {
        target: handles.menu
        function onWidthChanged() { handles.noteSystemResize(); }
        function onHeightChanged() { handles.noteSystemResize(); }
    }
    function noteSystemResize() {
        if (systemResizing) {
            sawSizeChange = true;
            settleTimer.restart();
        }
    }
    // While KWin resizes, the menu gets no mouse events; the first one after
    // means the drag is over. The timer is a backup for when none arrives.
    HoverHandler {
        enabled: handles.systemResizing && handles.sawSizeChange
        onPointChanged: handles.finishSystemResize()
    }
    Timer {
        id: settleTimer
        interval: 900
        onTriggered: handles.finishSystemResize()
    }
    function finishSystemResize() {
        if (!systemResizing) {
            return;
        }
        systemResizing = false;
        settleTimer.stop();
        if (sawSizeChange) {
            cfg.menuWidth = Math.round(menu.width);
            cfg.menuHeight = Math.round(menu.height);
            lw.positionMenu();          // re-centre / re-pin to the taskbar
        }
        sawSizeChange = false;
        sizeLabelTimer.restart();
    }

    // ---- Symmetric resizing (centred menu): done by Launchwell, frame-synced.
    // The window manager's own resize always keeps the opposite edge still, so a
    // centred menu would grow lopsided. Here the new size is drawn first and the
    // window is re-centred only once that frame is on screen, so the move and the
    // resize never arrive out of order (which is what made it flicker before).
    property var activeGrip: null
    property bool awaitingFrame: false

    Connections {
        target: handles.lw.menuWindow
        function onFrameSwapped() {
            if (handles.awaitingFrame) {
                handles.awaitingFrame = false;
                frameSafety.stop();
                handles.lw.positionMenu();
                if (handles.activeGrip && handles.activeGrip.hasPending) {
                    Qt.callLater(handles.applyPending);
                }
            }
        }
    }
    Timer {
        // in case a frame never comes (e.g. size was clamped and didn't change)
        id: frameSafety
        interval: 100
        onTriggered: {
            if (handles.awaitingFrame) {
                handles.awaitingFrame = false;
                handles.lw.positionMenu();
                if (handles.activeGrip && handles.activeGrip.hasPending) {
                    handles.applyPending();
                }
            }
        }
    }
    function applyPending() {
        const g = activeGrip;
        if (!g || !g.hasPending || awaitingFrame) {
            return;
        }
        g.hasPending = false;
        const p = g.pending;
        const oldW = menu.dragW, oldH = menu.dragH;
        if (g.sx !== 0) {
            menu.dragW = Math.round(Tools.clamp(g.startW + g.sx * (p.x - g.start.x) * hFactor, 360, maxW));
        }
        if (g.sy !== 0) {
            menu.dragH = Math.round(Tools.clamp(g.startH + g.sy * (p.y - g.start.y) * vFactor, 300, maxH));
        }
        if (menu.dragW !== oldW || menu.dragH !== oldH) {
            awaitingFrame = true;           // re-centre after this size is drawn
            frameSafety.restart();
        }
    }

    component Grip: MouseArea {
        id: g
        property int sx: 0          // -1 left edge, 1 right edge
        property int sy: 0          // -1 top edge, 1 bottom edge
        property bool manual: false
        property point start
        property real startW
        property real startH
        property point pending
        property bool hasPending: false
        readonly property int edges: (sx < 0 ? Qt.LeftEdge : sx > 0 ? Qt.RightEdge : 0)
                                     | (sy < 0 ? Qt.TopEdge : sy > 0 ? Qt.BottomEdge : 0)
        // Centred directions must grow on both sides at once
        readonly property bool needsSymmetric: (sx !== 0 && handles.hFactor === 2) || (sy !== 0 && handles.vFactor === 2)

        hoverEnabled: true
        preventStealing: true
        cursorShape: (sx !== 0 && sy !== 0) ? (sx === sy ? Qt.SizeFDiagCursor : Qt.SizeBDiagCursor)
                   : sx !== 0 ? Qt.SizeHorCursor : Qt.SizeVerCursor

        onPressed: (m) => {
            // Edges that grow one way only (e.g. the top edge above a bottom
            // taskbar): let the window manager do it - perfectly smooth.
            if (!needsSymmetric && handles.lw.startSystemResize(edges)) {
                manual = false;
                handles.sawSizeChange = false;
                handles.systemResizing = true;
                settleTimer.restart();
                return;
            }
            manual = true;
            hasPending = false;
            handles.activeGrip = g;
            handles.awaitingFrame = false;
            start = mapToGlobal(m.x, m.y);
            startW = handles.menu.baseW;
            startH = handles.menu.baseH;
            handles.menu.dragW = startW;
            handles.menu.dragH = startH;
        }
        onPositionChanged: (m) => {
            if (!pressed || !manual) {
                return;
            }
            pending = mapToGlobal(m.x, m.y);
            hasPending = true;
            handles.applyPending();          // waits its turn if a frame is pending
        }
        function finish() {
            if (!manual) {
                return;
            }
            manual = false;
            handles.activeGrip = null;
            handles.awaitingFrame = false;
            frameSafety.stop();
            handles.commit();
            handles.lw.positionMenu();
        }
        onReleased: (m) => {
            if (manual) {
                pending = mapToGlobal(m.x, m.y);
                hasPending = true;
                handles.awaitingFrame = false;
                handles.applyPending();
            }
            finish();
        }
        onCanceled: finish()
    }

    function commit() {
        if (menu.dragW > 0) {
            cfg.menuWidth = Math.round(menu.dragW);
            cfg.menuHeight = Math.round(menu.dragH);
        }
        menu.dragW = -1;
        menu.dragH = -1;
        sizeLabelTimer.restart();
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

    // Live size readout while dragging (and briefly after)
    Timer {
        id: sizeLabelTimer
        interval: 900
    }
    Rectangle {
        anchors.centerIn: parent
        visible: handles.menu.dragW > 0 || handles.systemResizing || sizeLabelTimer.running
        width: sizeText.implicitWidth + 24
        height: sizeText.implicitHeight + 12
        radius: height / 2
        color: Qt.rgba(0, 0, 0, 0.7)
        Text {
            id: sizeText
            anchors.centerIn: parent
            color: "white"
            font.bold: true
            text: Math.round(handles.menu.width) + " × " + Math.round(handles.menu.height)
        }
    }
}
