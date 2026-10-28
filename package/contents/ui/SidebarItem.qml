import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

// One row in the category sidebar.
Item {
    id: item

    property string text
    property var iconSource
    property bool selected: false
    property bool keyboardFocus: false
    property bool classicAllowed: true
    readonly property var cfg: Plasmoid.configuration
    readonly property real textScale: Math.max(50, cfg.textScale) / 100

    signal activate()
    signal contextRequested(real x, real y)

    implicitHeight: Math.max(cfg.categoryIconSize, label.implicitHeight) + Kirigami.Units.smallSpacing * 2 + cfg.rowSpacing * 2
    height: implicitHeight

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Kirigami.Units.smallSpacing
        color: Kirigami.Theme.highlightColor
        opacity: item.selected ? (item.keyboardFocus ? 0.45 : 0.3) : (mouse.containsMouse ? 0.12 : 0)
        Behavior on opacity {
            enabled: item.cfg.smoothHover && !(item.cfg.respectPlasmaSpeed && Kirigami.Units.longDuration <= 1)
            NumberAnimation { duration: item.cfg.hoverDuration; easing.type: Easing.OutCubic }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.rightMargin: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        IconBox {
            Layout.alignment: Qt.AlignVCenter
            source: item.iconSource
            size: item.cfg.categoryIconSize
            mono: item.cfg.categoryIconStyle === 1
            classic: item.classicAllowed && item.cfg.categoryIconStyle === 0
            forceColour: item.cfg.forceColour
            active: item.selected
        }

        PC3.Label {
            id: label
            Layout.fillWidth: true
            text: item.text
            elide: Text.ElideRight
            maximumLineCount: 1
            textFormat: Text.PlainText
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * item.textScale
        }
    }

    // Small delay so sweeping the mouse diagonally to the app list
    // doesn't flick through every category on the way.
    Timer {
        id: hoverTimer
        interval: 150
        onTriggered: if (mouse.containsMouse) item.activate()
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onContainsMouseChanged: {
            if (containsMouse && item.cfg.switchOnHover) {
                hoverTimer.restart();
            }
        }
        onClicked: (ev) => {
            if (ev.button === Qt.RightButton) {
                item.contextRequested(ev.x, ev.y);
            } else {
                item.activate();
            }
        }
    }
}
