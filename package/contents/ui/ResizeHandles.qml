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
            startW = handles.menu.baseW;
            startH = handles.menu.baseH;
            handles.menu.dragW = startW;
            handles.menu.dragH = startH;
        }
        onPositionChanged: (m) => {
            if (!pressed) {
                return;
            }
            const p = mapToGlobal(m.x, m.y);
            if (sx !== 0) {
                handles.menu.dragW = Math.round(Tools.clamp(startW + sx * (p.x - start.x) * handles.hFactor, 360, handles.maxW));
            }
            if (sy !== 0) {
                handles.menu.dragH = Math.round(Tools.clamp(startH + sy * (p.y - start.y) * handles.vFactor, 300, handles.maxH));
            }
            handles.lw.positionMenu();
        }
        onReleased: handles.commit()
        onCanceled: handles.commit()
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
        visible: handles.menu.dragW > 0 || sizeLabelTimer.running
        width: sizeText.implicitWidth + 24
        height: sizeText.implicitHeight + 12
        radius: height / 2
        color: Qt.rgba(0, 0, 0, 0.7)
        Text {
            id: sizeText
            anchors.centerIn: parent
            color: "white"
            font.bold: true
            text: Math.round(handles.menu.baseW) + " × " + Math.round(handles.menu.baseH)
        }
    }
}
