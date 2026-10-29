/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Item {
    id: del

    required property int index
    required property var model
    property var owner
    readonly property var cfg: Plasmoid.configuration
    readonly property bool isCurrent: ListView.isCurrentItem
    readonly property real textScale: Math.max(50, cfg.textScale) / 100
    readonly property string titleText: model.display || ""
    readonly property string descText: model.description || ""
    // Letter heading shown above this row ("" = none)
    property string heading: ""
    readonly property real headingHeight: heading.length > 0 ? headingLabel.implicitHeight + Kirigami.Units.smallSpacing * 2 : 0
    readonly property real rowHeight: Math.max(cfg.appIconSize, textCol.implicitHeight) + Kirigami.Units.smallSpacing * 2 + cfg.rowSpacing * 2

    implicitHeight: headingHeight + rowHeight
    height: implicitHeight

    // ---- letter heading (click to jump to another letter)
    Item {
        id: headingArea
        width: parent.width
        height: del.headingHeight
        visible: del.heading.length > 0
        Rectangle {
            anchors.fill: parent
            radius: Kirigami.Units.smallSpacing
            color: Kirigami.Theme.highlightColor
            opacity: headingMouse.containsMouse ? 0.12 : 0
        }
        PC3.Label {
            id: headingLabel
            anchors.verticalCenter: parent.verticalCenter
            x: Kirigami.Units.largeSpacing
            text: del.heading
            font.bold: true
            opacity: headingMouse.containsMouse ? 1 : 0.6
        }
        MouseArea {
            id: headingMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (del.owner) del.owner.openLetterPicker()
        }
    }

    // ---- the app row itself
    Item {
        id: rowArea
        y: del.headingHeight
        width: parent.width
        height: del.rowHeight
    }

    function openMenu(x, y) {
        owner.contextMenuRequested(index, model, del,
                                     x === undefined ? width / 2 : x,
                                     y === undefined ? height / 2 : y);
    }

    Rectangle {
        anchors.fill: rowArea
        anchors.margins: 1
        radius: Kirigami.Units.smallSpacing
        color: Kirigami.Theme.highlightColor
        opacity: del.isCurrent ? 0.3 : (mouse.containsMouse ? 0.12 : 0)
        Behavior on opacity {
            enabled: del.cfg.smoothHover && !(del.cfg.respectPlasmaSpeed && Kirigami.Units.longDuration <= 1)
            NumberAnimation { duration: del.cfg.hoverDuration; easing.type: Easing.OutCubic }
        }
    }

    RowLayout {
        anchors.fill: rowArea
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.rightMargin: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        IconBox {
            Layout.alignment: Qt.AlignVCenter
            source: del.model.decoration
            size: del.cfg.appIconSize
            mono: del.cfg.appIconStyle === 1
            forceColour: del.cfg.forceColour
        }

        ColumnLayout {
            id: textCol
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            PC3.Label {
                Layout.fillWidth: true
                text: del.titleText
                elide: Text.ElideRight
                maximumLineCount: 1
                textFormat: Text.PlainText
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * del.textScale
            }
            PC3.Label {
                Layout.fillWidth: true
                visible: del.cfg.showDescriptions && del.descText.length > 0 && del.descText !== del.titleText
                text: del.descText
                elide: Text.ElideRight
                maximumLineCount: 1
                textFormat: Text.PlainText
                opacity: 0.65
                font.pointSize: Kirigami.Theme.smallFont.pointSize * del.textScale
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: rowArea
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onContainsMouseChanged: {
            if (containsMouse && del.ListView.view) {
                del.ListView.view.currentIndex = del.index;
            }
        }
        onClicked: (ev) => {
            if (ev.button === Qt.RightButton) {
                del.openMenu(ev.x, ev.y);
            } else {
                if (del.owner) {
                    del.owner.trigger(del.index);
                }
            }
        }
    }
}
