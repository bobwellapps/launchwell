/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import "tools.js" as Tools

// A list or grid of launchable items (apps, favourites or search results).
FocusScope {
    id: appView

    property var model: null
    property bool gridMode: false
    property bool showSections: false
    property bool isFavourites: false
    property bool autoSelectFirst: false
    property string emptyText: ""
    property string emptyIcon: ""
    readonly property var cfg: Plasmoid.configuration
    readonly property bool animsOff: cfg.respectPlasmaSpeed && Kirigami.Units.longDuration <= 1
    readonly property bool cascade: cfg.cascadeItems && !animsOff
    readonly property Item view: loader.item
    readonly property int count: model ? model.count : 0

    signal launched()
    signal leaveTop()   // keyboard moved up past the first row
    signal contextMenuRequested(int row, var data, Item item, real x, real y)

    function trigger(row) {
        if (!model || row < 0 || row >= model.count) {
            return;
        }
        try {
            model.trigger(row, "", null);
        } catch (e) {
            console.warn("Launchwell: launch failed", e);
        }
        launched();
    }
    function triggerCurrentOrFirst() {
        if (view) {
            trigger(view.currentIndex >= 0 ? view.currentIndex : 0);
        }
    }
    function focusFirst() {
        if (!view || count === 0) {
            return;
        }
        keyboardLeads();
        if (view.currentIndex < 0) {
            view.currentIndex = 0;
        }
        view.forceActiveFocus();
    }
    function resetView() {
        keyboardLeads();
        if (view) {
            view.currentIndex = -1;
            view.positionViewAtBeginning();
        }
    }
    function selectFirst() {
        if (view && !view.activeFocus) {
            view.currentIndex = count > 0 ? 0 : -1;
            view.positionViewAtBeginning();
        }
    }
    // Typing: the top row is selected again and the mouse waits until it moves.
    function typed() {
        keyboardLeads();
        selectFirst();
    }

    // ------------------------------------------------ pointer vs. keyboard
    // Rows that turn up under a resting pointer (search results rebuilt on every
    // keystroke, a list scrolled with the arrow keys, the menu opening under the
    // cursor) must not take the selection. After keyboard use the pointer selects
    // again only once it has really moved, further than about 1.5 mm, so a mouse
    // nudged while typing doesn't count.
    property bool pointerMoved: false
    property var pointerAnchor: null    // where the pointer was first seen since then
    // Screen.pixelDensity is in logical pixels per mm (0 if the screen reports no size)
    readonly property real pointerDeadband: Tools.clamp(Screen.pixelDensity > 0.5 ? Screen.pixelDensity * 1.5
                                                                                   : Kirigami.Units.gridUnit / 4, 3, 16)

    function keyboardLeads() {
        pointerMoved = false;
        pointerAnchor = null;
    }
    // A row reports the pointer entering or moving over it (x, y in item's coordinates).
    function pointerOver(row, item, x, y) {
        if (!pointerMoved) {
            const p = item.mapToItem(null, x, y);
            if (!pointerAnchor) {
                pointerAnchor = p;
                return;
            }
            if (Math.hypot(p.x - pointerAnchor.x, p.y - pointerAnchor.y) <= pointerDeadband) {
                return;
            }
            pointerMoved = true;
        }
        if (view) {
            view.currentIndex = row;
        }
    }

    // ------------------------------------------------ letter jump (A-Z picker)
    property bool letterPickerOpen: false
    property var letters: []

    function letterOf(row) {
        return Tools.letterFor(model.data(model.index(row, 0), Qt.DisplayRole));
    }
    // Heading to show above a row: its letter when it differs from the row above.
    // (Drawn by the row itself: Qt's built-in section headings show stale
    // letters when they get reused while scrolling.)
    function headingFor(row) {
        void count;
        if (!showSections || !model || row < 0 || row >= count) {
            return "";
        }
        const c = letterOf(row);
        return (row === 0 || letterOf(row - 1) !== c) ? c : "";
    }
    function openLetterPicker() {
        if (!model || count === 0) {
            return;
        }
        const out = [];
        for (let i = 0; i < count; ++i) {
            const c = letterOf(i);
            if (out.indexOf(c) === -1) {
                out.push(c);
            }
        }
        letters = out;
        letterPickerOpen = true;
        letterPicker.forceActiveFocus();
    }
    function jumpToLetter(c) {
        letterPickerOpen = false;
        for (let i = 0; i < count; ++i) {
            if (letterOf(i) === c) {
                view.currentIndex = i;
                view.positionViewAtIndex(i, ListView.Beginning);
                view.forceActiveFocus();
                return;
            }
        }
    }

    onCountChanged: if (autoSelectFirst && !pointerMoved) selectFirst()
    onModelChanged: {
        letterPickerOpen = false;
        autoSelectFirst ? selectFirst() : resetView();
    }
    onVisibleChanged: {
        if (visible) {
            keyboardLeads();    // e.g. back from search: the view reappears under a resting pointer
        } else {
            letterPickerOpen = false;
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        focus: true
        sourceComponent: appView.gridMode ? gridComponent : listComponent
    }

    PlasmaExtras.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - Kirigami.Units.gridUnit * 4
        visible: appView.emptyText.length > 0 && appView.count === 0
        text: appView.emptyText
        iconName: appView.emptyIcon
    }

    // The A-Z grid shown when a letter heading is clicked
    FocusScope {
        id: letterPicker
        anchors.fill: parent
        visible: appView.letterPickerOpen
        z: 10
        Keys.onEscapePressed: appView.letterPickerOpen = false
        Keys.onPressed: (event) => {
            const c = event.text.toUpperCase();
            if (c.length === 1 && appView.letters.indexOf(c) !== -1) {
                appView.jumpToLetter(c);
                event.accepted = true;
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: Kirigami.Units.smallSpacing * 2
            color: Kirigami.Theme.backgroundColor
            opacity: 0.94
        }
        // clicking empty space closes the grid
        MouseArea {
            anchors.fill: parent
            onClicked: appView.letterPickerOpen = false
        }

        Grid {
            anchors.centerIn: parent
            readonly property real cell: Kirigami.Units.gridUnit * 2.4
            columns: Math.max(1, Math.min(7, Math.floor((letterPicker.width - Kirigami.Units.gridUnit * 2) / (cell + spacing))))
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: appView.letters
                delegate: PC3.ToolButton {
                    required property string modelData
                    width: parent.cell
                    height: parent.cell
                    text: modelData
                    font.bold: true
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.3
                    onClicked: appView.jumpToLetter(modelData)
                }
            }
        }
    }

    Component {
        id: listComponent

        ListView {
            id: list
            clip: true
            focus: true
            model: appView.model
            currentIndex: -1
            keyNavigationEnabled: true
            highlightMoveDuration: 0
            boundsBehavior: Flickable.StopAtBounds
            QQC2.ScrollBar.vertical: PC3.ScrollBar { id: listBar }
            // Row width that stays clear of the scrollbar when it's showing
            readonly property real rowWidth: width - ((listBar.size < 1 && listBar.policy !== QQC2.ScrollBar.AlwaysOff)
                                                      ? listBar.width + Kirigami.Units.smallSpacing : 0)

            // Apps fade in one after another when the list fills
            populate: Transition {
                id: listCascade
                enabled: appView.cascade
                SequentialAnimation {
                    PropertyAction { property: "opacity"; value: 0 }
                    PauseAnimation { duration: Math.min(listCascade.ViewTransition.index, 30) * appView.cfg.cascadeDelay }
                    NumberAnimation { property: "opacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }
                }
            }

            delegate: AppListDelegate {
                owner: appView
                width: list.rowWidth
                heading: appView.headingFor(index)
            }

            Keys.onReturnPressed: appView.trigger(currentIndex)
            Keys.onEnterPressed: appView.trigger(currentIndex)
            Keys.onMenuPressed: if (currentItem) currentItem.openMenu()
            Keys.onPressed: appView.keyboardLeads()     // arrow keys etc.; the view still handles them
            Keys.onUpPressed: {
                appView.keyboardLeads();
                if (currentIndex <= 0) {
                    appView.leaveTop();
                } else {
                    decrementCurrentIndex();
                }
            }
        }
    }

    Component {
        id: gridComponent

        GridView {
            id: grid
            clip: true
            focus: true
            model: appView.model
            currentIndex: -1
            keyNavigationEnabled: true
            highlightMoveDuration: 0
            boundsBehavior: Flickable.StopAtBounds
            QQC2.ScrollBar.vertical: PC3.ScrollBar { id: gridBar }
            readonly property real rowWidth: width - ((gridBar.size < 1 && gridBar.policy !== QQC2.ScrollBar.AlwaysOff)
                                                      ? gridBar.width + Kirigami.Units.smallSpacing : 0)

            // Apps fade in one after another when the list fills
            populate: Transition {
                id: gridCascade
                enabled: appView.cascade
                SequentialAnimation {
                    PropertyAction { property: "opacity"; value: 0 }
                    PauseAnimation { duration: Math.min(gridCascade.ViewTransition.index, 30) * appView.cfg.cascadeDelay }
                    NumberAnimation { property: "opacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }
                }
            }

            readonly property real textScale: Math.max(50, appView.cfg.textScale) / 100
            readonly property int columns: Math.max(1, Math.floor(rowWidth / (appView.cfg.gridIconSize + Kirigami.Units.gridUnit * 3)))
            cellWidth: Math.floor(rowWidth / columns)
            cellHeight: appView.cfg.gridIconSize + Kirigami.Units.gridUnit * 2.6 * textScale + Kirigami.Units.largeSpacing * 2

            delegate: AppGridDelegate {
                owner: appView
                width: grid.cellWidth
                height: grid.cellHeight
            }

            Keys.onReturnPressed: appView.trigger(currentIndex)
            Keys.onEnterPressed: appView.trigger(currentIndex)
            Keys.onMenuPressed: if (currentItem) currentItem.openMenu()
            Keys.onPressed: appView.keyboardLeads()     // arrow keys etc.; the view still handles them
            Keys.onUpPressed: {
                appView.keyboardLeads();
                if (currentIndex < columns) {
                    appView.leaveTop();
                } else {
                    moveCurrentIndexUp();
                }
            }
        }
    }
}
