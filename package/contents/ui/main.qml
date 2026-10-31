/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
/*
 * Launchwell - a Kickoff-style application launcher for Plasma 6
 * with colour icons and a freely positioned popup.
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.kicker as Kicker
import "tools.js" as Tools

PlasmoidItem {
    id: launcher

    readonly property var cfg: Plasmoid.configuration
    property Item buttonItem: null
    property double lastClosed: 0
    property string searchText: ""
    // True between clicking an app and that app's window appearing (menu see-through)
    // True while the closing animation plays
    property bool closing: false
    readonly property bool menuOpen: menuDialog.visible && !closing

    Plasmoid.icon: cfg.icon
    // The panel button IS the widget (like "Show Desktop"); the menu is our own window.
    preferredRepresentation: fullRepresentation
    activationTogglesExpanded: false
    toolTipMainText: ""
    toolTipSubText: ""

    fullRepresentation: LauncherButton {
        lw: launcher
    }

    // Screen and panel window of this widget, used to place the menu.
    readonly property rect screenRect: Qt.rect(Screen.virtualX, Screen.virtualY, Screen.width, Screen.height)
    readonly property var panelWindow: Window.window

    // ---------------------------------------------------------------- models

    property Kicker.RootModel rootModel: Kicker.RootModel {
        autoPopulate: false
        flat: true
        sorted: launcher.cfg.alphaSort
        showSeparators: false
        showAllApps: true
        showRecentApps: launcher.cfg.showRecentApps
        showRecentDocs: launcher.cfg.showRecentDocs
        appNameFormat: launcher.cfg.appNameFormat
    }

    property Kicker.RunnerModel runnerModel: Kicker.RunnerModel {
        query: launcher.searchText
        mergeResults: true
    }

    property Kicker.SystemModel systemModel: Kicker.SystemModel {}

    // Refresh the app tree when a setting that shapes it changes.
    readonly property string modelConfigKey: [cfg.alphaSort, cfg.showRecentApps, cfg.showRecentDocs, cfg.appNameFormat].join(",")
    onModelConfigKeyChanged: Qt.callLater(refreshModels)

    readonly property bool newAppBadge: cfg.newAppBadge
    onNewAppBadgeChanged: {
        Tools.setIfExists(rootModel, "highlightNewlyInstalledApps", newAppBadge);
        Qt.callLater(refreshModels);
    }

    readonly property bool extendedSearch: cfg.extendedSearch
    onExtendedSearchChanged: applyRunners()

    function refreshModels() {
        rootModel.refresh();
    }

    function applyRunners() {
        // Empty list = use whatever KRunner itself has enabled (files, web shortcuts, ...)
        const basic = ["krunner_services", "krunner_systemsettings", "krunner_sessions",
                       "krunner_powerdevil", "calculator", "unitconverter"];
        Tools.setIfExists(runnerModel, "runners", cfg.extendedSearch ? [] : basic);
    }

    Component.onCompleted: {
        // Properties that have moved around between Plasma releases are set defensively.
        Tools.setIfExists(rootModel, "appletInterface", launcher);
        Tools.setIfExists(rootModel, "showPowerSession", false);
        Tools.setIfExists(rootModel, "showAllAppsCategorized", false);
        Tools.setIfExists(rootModel, "showTopLevelItems", false);
        Tools.setIfExists(rootModel, "showFavoritesPlaceholder", false);
        // Plasma tracks newly installed apps (3 days, or until first opened)
        Tools.setIfExists(rootModel, "highlightNewlyInstalledApps", cfg.newAppBadge);
        Tools.setIfExists(runnerModel, "appletInterface", launcher);
        Tools.setIfExists(runnerModel, "favoritesModel", rootModel.favoritesModel);
        Tools.setIfExists(systemModel, "favoritesModel", rootModel.systemFavoritesModel);
        applyRunners();

        const fav = rootModel.favoritesModel;
        if (fav && typeof fav.initForClient === "function") {
            fav.initForClient("org.launchwell.favorites.instance-" + Plasmoid.id);
            if (!cfg.favouritesSeeded) {
                if (fav.count < 1 && typeof fav.portOldFavorites === "function") {
                    fav.portOldFavorites(["preferred://browser", "org.kde.dolphin.desktop",
                                          "org.kde.konsole.desktop", "systemsettings.desktop",
                                          "org.kde.discover.desktop"]);
                }
                cfg.favouritesSeeded = true;
            }
        }
        rootModel.refresh();
    }

    // ---------------------------------------------------------------- update check
    // Once a day, ask GitHub for the newest release. Only reads public
    // release info; never downloads or installs anything by itself.
    property string updateVersion: ""
    property string updateUrl: ""
    readonly property bool canCheckUpdates: cfg.checkUpdates && Tools.updateRepo.length > 0
    readonly property bool updateAvailable: canCheckUpdates && updateVersion.length > 0
                                            && updateVersion !== cfg.skippedVersion

    Timer {
        // first check a minute after login, so it doesn't slow start-up
        interval: 60 * 1000
        running: launcher.canCheckUpdates
        onTriggered: launcher.checkForUpdates()
    }
    Timer {
        interval: 24 * 60 * 60 * 1000
        repeat: true
        running: launcher.canCheckUpdates
        onTriggered: launcher.checkForUpdates()
    }

    function checkForUpdates() {
        if (!canCheckUpdates) {
            return;
        }
        const repo = Tools.updateRepo;
        fetchJson("https://api.github.com/repos/" + repo + "/releases/latest", (j) => {
            if (j && j.tag_name) {
                gotLatest(j.tag_name, j.html_url || ("https://github.com/" + repo + "/releases/latest"));
                return;
            }
            // No release found (or the API said no): read the version on the main branch
            fetchJson("https://raw.githubusercontent.com/" + repo + "/HEAD/package/metadata.json", (m) => {
                if (m && m.KPlugin && m.KPlugin.Version) {
                    gotLatest(m.KPlugin.Version, "https://github.com/" + repo + "/releases");
                }
            });
        });
    }
    function gotLatest(version, url) {
        const v = String(version).replace(/^v/i, "");
        if (Tools.isNewer(v, Tools.version)) {
            updateVersion = v;
            updateUrl = url;
        } else {
            updateVersion = "";
        }
    }
    function fetchJson(url, done) {
        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = () => {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return;
            }
            let data = null;
            if (xhr.status === 200) {
                try {
                    data = JSON.parse(xhr.responseText);
                } catch (e) {
                    data = null;
                }
            }
            done(data);
        };
        xhr.open("GET", url);
        xhr.setRequestHeader("Accept", "application/vnd.github+json");
        xhr.send();
    }
    function openUpdatePage() {
        if (updateUrl) {
            Qt.openUrlExternally(updateUrl);
            closeMenuAfterLaunch();
        }
    }

    // ---------------------------------------------------------------- open / close

    Connections {
        target: Plasmoid
        function onActivated() {
            launcher.menuOpen ? launcher.closeMenu() : launcher.openMenu();
        }
    }

    function openMenu() {
        if (closing) {
            // reopened while the closing animation runs: just play it back open
            closing = false;
            menuContent.stopClose();
            menuContent.playOpen();
            menuDialog.requestActivate();
            menuContent.focusSearch();
            return;
        }
        if (menuDialog.visible) {
            return;
        }
        focusKeeper.visible = false;
        focusKeeperTimer.stop();
        menuContent.prepare();
        positionMenu();
        menuDialog.visible = true;
        menuDialog.requestActivate();
        menuContent.focusSearch();
        menuContent.playOpen();
        Qt.callLater(positionMenu);
    }

    function closeMenu() {
        if (closing) {
            return;
        }
        if (menuDialog.visible && menuContent.playClose()) {
            closing = true;            // finishClose() runs when the animation ends
            return;
        }
        finishClose();
    }

    function finishClose() {
        closing = false;
        menuDialog.visible = false;
    }

    // After launching an app (or opening a settings window):
    // KWin puts a new window on the "active monitor" at the moment it appears.
    // Closing the menu hands focus - and the active monitor - to whatever was
    // focused before, possibly on the other monitor. So a tiny invisible helper
    // window on the menu's monitor takes focus first and holds it until the new
    // window appears (it then loses focus and hides itself). The menu itself
    // closes normally and instantly, with no change to its frame or size.
    function closeMenuAfterLaunch() {
        focusKeeper.x = menuDialog.x + Math.round(menuDialog.width / 2);
        focusKeeper.y = menuDialog.y + Math.round(menuDialog.height / 2);
        focusKeeper.visible = true;
        focusKeeper.requestActivate();
        focusKeeperTimer.restart();
        menuContent.stopClose();
        finishClose();
    }

    PlasmaCore.Dialog {
        id: focusKeeper
        visible: false
        location: PlasmaCore.Types.Floating
        type: PlasmaCore.Dialog.AppletPopup
        flags: Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint
        backgroundHints: PlasmaCore.Dialog.NoBackground
        hideOnWindowDeactivate: true
        mainItem: Item {
            width: 1
            height: 1
        }
        onVisibleChanged: if (!visible) focusKeeperTimer.stop()
    }

    Timer {
        id: focusKeeperTimer
        interval: 5000              // safety net if the app never opens a window
        onTriggered: focusKeeper.visible = false
    }

    function dialogType() {
        switch (cfg.windowType) {
        case 1: return PlasmaCore.Dialog.Normal;
        case 2: return PlasmaCore.Dialog.PopupMenu;
        default: return PlasmaCore.Dialog.AppletPopup;
        }
    }

    // ---------------------------------------------------------------- positioning

    // Where the menu should be, for its current size
    // Where the menu should be for a given content size (default: its current size)
    function menuTargetPosition(cw, ch) {
        const m = menuDialog.margins;
        const W = (cw !== undefined ? cw : menuContent.width) + (m ? m.left + m.right : 0);
        const H = (ch !== undefined ? ch : menuContent.height) + (m ? m.top + m.bottom : 0);

        const loc = Plasmoid.location;
        const sidePanel = loc === PlasmaCore.Types.LeftEdge || loc === PlasmaCore.Types.RightEdge;
        const inPanel = sidePanel || loc === PlasmaCore.Types.TopEdge || loc === PlasmaCore.Types.BottomEdge;

        const scr = (screenRect.width > 0 && screenRect.height > 0) ? screenRect : Qt.rect(0, 0, 1920, 1080);
        const win = panelWindow;
        // Panel thickness from the panel window's size (reliable on Wayland,
        // where a window's own screen position is often reported as 0,0).
        const thick = win ? (sidePanel ? win.width : win.height) : Kirigami.Units.gridUnit * 2;
        const winX = (win && win.x > scr.x && win.x < scr.x + scr.width) ? win.x : scr.x;
        const winY = (win && win.y > scr.y && win.y < scr.y + scr.height) ? win.y : scr.y;

        // Centre of the launcher button along the panel
        const btn = buttonItem || launcher;
        const p = btn.mapToItem(null, btn.width / 2, btn.height / 2);
        const btnX = winX + p.x;
        const btnY = winY + p.y;

        const gap = cfg.verticalGap;
        let x, y;

        // Horizontal
        if (sidePanel) {
            x = loc === PlasmaCore.Types.LeftEdge ? scr.x + thick + gap : scr.x + scr.width - thick - W - gap;
        } else {
            switch (cfg.horizontalPosition) {
            case 1:  x = btnX - W / 2; break;                         // centred on the button
            case 2:  x = scr.x + gap; break;                          // left edge
            case 3:  x = scr.x + scr.width - W - gap; break;          // right edge
            default: x = scr.x + (scr.width - W) / 2; break;          // screen centre
            }
        }
        x += cfg.horizontalOffset;

        // Vertical
        switch (cfg.verticalPosition) {
        case 1:  y = scr.y + (scr.height - H) / 2; break;             // screen centre
        case 2:  y = scr.y + gap; break;                              // top of screen
        default:                                                      // next to the panel
            if (loc === PlasmaCore.Types.TopEdge) {
                y = scr.y + thick + gap;
            } else if (sidePanel) {
                y = btnY - H / 2;
            } else if (inPanel) {
                y = scr.y + scr.height - thick - H - gap;             // bottom panel
            } else {
                y = btnY - H - gap;                                   // widget on the desktop
            }
            break;
        }
        y -= cfg.verticalOffset;                                      // positive = up

        if (cfg.keepOnScreen) {
            x = Tools.clamp(x, scr.x, scr.x + scr.width - W);
            y = Tools.clamp(y, scr.y, scr.y + scr.height - H);
        }
        return Qt.point(Math.round(x), Math.round(y));
    }

    function positionMenu() {
        glideAnim.stop();
        const p = menuTargetPosition();
        menuDialog.x = p.x;
        menuDialog.y = p.y;
    }

    // Slide (move only, no resizing, so no flicker) to where the menu belongs.
    // Used after an edge drag, to re-centre a menu that grew on one side.
    function glideToPosition() {
        const p = menuTargetPosition();
        if (p.x === menuDialog.x && p.y === menuDialog.y) {
            return;
        }
        if (Kirigami.Units.longDuration <= 1) {
            positionMenu();
            return;
        }
        glideAnim.stop();
        glideX.from = menuDialog.x;
        glideX.to = p.x;
        glideY.from = menuDialog.y;
        glideY.to = p.y;
        glideAnim.start();
    }
    ParallelAnimation {
        id: glideAnim
        NumberAnimation { id: glideX; target: menuDialog; property: "x"; duration: 160; easing.type: Easing.OutCubic }
        NumberAnimation { id: glideY; target: menuDialog; property: "y"; duration: 160; easing.type: Easing.OutCubic }
    }

    // Re-place the menu live if size/position settings change while it is open.
    readonly property string positionKey: [cfg.menuWidth, cfg.menuHeight, cfg.horizontalPosition,
        cfg.horizontalOffset, cfg.verticalPosition, cfg.verticalGap, cfg.verticalOffset,
        cfg.keepOnScreen, cfg.backgroundStyle].join(",")
    // After a drag-resize: jump to the new place in one step (snapPosition);
    // otherwise slide there.
    property bool snapPosition: false
    onPositionKeyChanged: {
        if (!menuDialog.visible) {
            snapPosition = false;
            return;
        }
        if (snapPosition) {
            snapPosition = false;
            positionMenu();
            Qt.callLater(positionMenu);     // again once the new size has landed
        } else {
            Qt.callLater(glideToPosition);
        }
    }

    // ---------------------------------------------------------------- resize outline
    // A see-through, click-through overlay over the whole screen. While an edge
    // of the menu is dragged it draws an outline of the new size, exactly where
    // the menu will end up. The menu itself only changes when the drag ends.
    // Same outline for the menu to draw on top of itself (the overlay window
    // sits underneath the menu, so a shrinking outline would be hidden there)
    property rect resizeOutlineRect          // in screen coordinates, frame included
    property point resizeContentOrigin       // screen position of the menu's content
    property bool resizeOutlineShown: false

    function showResizeOutline(w, h) {
        const r = screenRect;
        const mm = menuDialog.margins;
        resizeContentOrigin = Qt.point(menuDialog.x + (mm ? mm.left : 0), menuDialog.y + (mm ? mm.top : 0));
        resizeOutlineShown = true;
        resizeOverlay.x = r.x;
        resizeOverlay.y = r.y;
        overlayItem.width = r.width;
        overlayItem.height = r.height;
        updateResizeOutline(w, h);
        resizeOverlay.visible = true;
    }
    function updateResizeOutline(w, h) {
        const m = menuDialog.margins;
        const p = menuTargetPosition(w, h);
        outlineBox.x = p.x - screenRect.x;
        outlineBox.y = p.y - screenRect.y;
        outlineBox.width = w + (m ? m.left + m.right : 0);
        outlineBox.height = h + (m ? m.top + m.bottom : 0);
        outlineLabel.text = Math.round(w) + " × " + Math.round(h);
        resizeOutlineRect = Qt.rect(p.x, p.y, outlineBox.width, outlineBox.height);
    }
    function hideResizeOutline() {
        resizeOutlineShown = false;
        resizeOverlay.visible = false;
    }

    PlasmaCore.Dialog {
        id: resizeOverlay
        visible: false
        location: PlasmaCore.Types.Floating
        // On-screen-display windows never take keyboard focus, so the menu
        // (which hides when it loses focus) stays open underneath.
        type: PlasmaCore.Dialog.OnScreenDisplay
        flags: Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint | Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus
        backgroundHints: PlasmaCore.Dialog.NoBackground
        hideOnWindowDeactivate: false
        Component.onCompleted: Tools.setIfExists(resizeOverlay, "outputOnly", true)

        mainItem: Item {
            id: overlayItem
            width: 100
            height: 100

            Rectangle {
                id: outlineBox
                radius: Kirigami.Units.cornerRadius !== undefined ? Kirigami.Units.cornerRadius : 6
                color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12)
                border.width: 2
                border.color: Kirigami.Theme.highlightColor

                Rectangle {
                    anchors.centerIn: parent
                    width: outlineLabel.implicitWidth + Kirigami.Units.gridUnit * 1.5
                    height: outlineLabel.implicitHeight + Kirigami.Units.smallSpacing * 3
                    radius: height / 2
                    color: Qt.rgba(0, 0, 0, 0.7)
                    Text {
                        id: outlineLabel
                        anchors.centerIn: parent
                        color: "white"
                        font.bold: true
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------------- the popup

    PlasmaCore.Dialog {
        id: menuDialog
        visible: false
        location: PlasmaCore.Types.Floating
        type: launcher.dialogType()
        flags: Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint
        hideOnWindowDeactivate: true
        backgroundHints: launcher.cfg.backgroundStyle >= 2 ? PlasmaCore.Dialog.NoBackground
                       : launcher.cfg.backgroundStyle === 1 ? PlasmaCore.Dialog.SolidBackground
                       : PlasmaCore.Dialog.StandardBackground

        mainItem: MenuContent {
            id: menuContent
            lw: launcher
        }

        onVisibleChanged: {
            if (!visible) {
                launcher.closing = false;
                launcher.lastClosed = Date.now();
                launcher.searchText = "";
            }
        }
    }
}
