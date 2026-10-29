/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

// The button that sits in the panel.
MouseArea {
    id: button

    required property var lw
    readonly property var cfg: Plasmoid.configuration
    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool horizontal: Plasmoid.formFactor === PlasmaCore.Types.Horizontal

    property bool wasOpen: false

    // Size like Kickoff: the panel's thickness decides the icon size, never 0.
    readonly property bool inPanel: [PlasmaCore.Types.TopEdge, PlasmaCore.Types.BottomEdge,
                                     PlasmaCore.Types.LeftEdge, PlasmaCore.Types.RightEdge].indexOf(Plasmoid.location) !== -1
    readonly property int panelHint: (Kirigami.Units.iconSizeHints && Kirigami.Units.iconSizeHints.panel > 0)
                                     ? Kirigami.Units.iconSizeHints.panel : Kirigami.Units.iconSizes.large
    readonly property real thickness: {
        const t = parent ? (vertical ? parent.width : parent.height) : 0;
        return t > 0 ? Math.min(button.panelHint, t) : Kirigami.Units.iconSizes.medium;
    }
    readonly property real labelWidth: label.visible ? label.implicitWidth + Kirigami.Units.smallSpacing * 2 : 0

    hoverEnabled: true
    implicitWidth: thickness + labelWidth
    implicitHeight: thickness
    Layout.minimumWidth: !inPanel ? button.panelHint : (vertical ? -1 : thickness + labelWidth)
    Layout.maximumWidth: !inPanel ? -1 : (vertical ? -1 : thickness + labelWidth)
    Layout.preferredWidth: !inPanel ? -1 : (vertical ? -1 : thickness + labelWidth)
    Layout.minimumHeight: !inPanel ? button.panelHint : (vertical ? thickness : -1)
    Layout.maximumHeight: !inPanel ? -1 : (vertical ? thickness : -1)
    Layout.preferredHeight: !inPanel ? -1 : (vertical ? thickness : -1)

    Component.onCompleted: lw.buttonItem = button
    Component.onDestruction: {
        if (lw.buttonItem === button) {
            lw.buttonItem = null;
        }
    }

    // Remember the state on press: clicking the panel can close the popup
    // (focus loss) before the click arrives, which would re-open it.
    onPressed: wasOpen = lw.menuOpen || (Date.now() - lw.lastClosed) < 300
    onClicked: wasOpen ? lw.closeMenu() : lw.openMenu()

    RowLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: !label.visible
            Layout.preferredWidth: button.thickness
            Layout.minimumWidth: button.thickness

            IconBox {
                anchors.centerIn: parent
                size: Math.max(16, Math.min(parent.width, parent.height))
                // 0 = classic colour Plasma logo (bundled), 1 = new Plasma 6 logo, 2 = custom
                source: button.cfg.buttonIconStyle === 2 ? (button.cfg.icon || "start-here-kde") : "start-here-kde"
                classic: button.cfg.buttonIconStyle === 0
                mono: button.cfg.buttonIconStyle === 1 || (button.cfg.buttonIconStyle === 2 && button.cfg.buttonIconMono)
                forceColour: true
                active: button.containsMouse || button.lw.menuOpen
            }
        }

        PC3.Label {
            id: label
            visible: button.horizontal && button.cfg.menuLabel.length > 0
            text: button.cfg.menuLabel
            Layout.rightMargin: Kirigami.Units.smallSpacing
        }
    }

    // Small dot when a Launchwell update is available
    Rectangle {
        visible: button.lw.updateAvailable
        width: Math.max(6, Math.round(button.thickness / 5))
        height: width
        radius: width / 2
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Math.round(button.thickness / 10)
        color: Kirigami.Theme.positiveTextColor
        border.width: 1
        border.color: Kirigami.Theme.backgroundColor
    }
}
