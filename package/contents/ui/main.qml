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

    function positionMenu() {
        const m = menuDialog.margins;
        const W = menuContent.width + (m ? m.left + m.right : 0);
        const H = menuContent.height + (m ? m.top + m.bottom : 0);

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
        menuDialog.x = Math.round(x);
        menuDialog.y = Math.round(y);
    }

    // Re-place the menu live if size/position settings change while it is open.
    readonly property string positionKey: [cfg.menuWidth, cfg.menuHeight, cfg.horizontalPosition,
        cfg.horizontalOffset, cfg.verticalPosition, cfg.verticalGap, cfg.verticalOffset,
        cfg.keepOnScreen, cfg.backgroundStyle].join(",")
    onPositionKeyChanged: if (menuDialog.visible) Qt.callLater(positionMenu)

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
