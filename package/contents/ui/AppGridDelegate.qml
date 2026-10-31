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
    readonly property bool isCurrent: GridView.isCurrentItem
    readonly property real textScale: Math.max(50, cfg.textScale) / 100

    function openMenu(x, y) {
        owner.contextMenuRequested(index, model, del,
                                     x === undefined ? width / 2 : x,
                                     y === undefined ? height / 2 : y);
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        radius: Kirigami.Units.smallSpacing * 2
        color: Kirigami.Theme.highlightColor
        opacity: del.isCurrent ? 0.3 : (mouse.containsMouse ? 0.12 : 0)
        Behavior on opacity {
            enabled: del.cfg.smoothHover && !(del.cfg.respectPlasmaSpeed && Kirigami.Units.longDuration <= 1)
            NumberAnimation { duration: del.cfg.hoverDuration; easing.type: Easing.OutCubic }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing * 2
        spacing: Kirigami.Units.smallSpacing

        IconBox {
            id: gridIcon
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.smallSpacing
            source: del.model.decoration
            size: del.cfg.gridIconSize
            mono: del.cfg.appIconStyle === 1
            forceColour: del.cfg.forceColour

            NewBadge {
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.top
                active: del.model.isNewlyInstalled === true
            }
        }

        PC3.Label {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: del.model.display || ""
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            textFormat: Text.PlainText
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * del.textScale
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onContainsMouseChanged: {
            if (containsMouse && del.GridView.view) {
                del.GridView.view.currentIndex = del.index;
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
