/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.coreaddons as KCoreAddons
import org.kde.kcmutils as KCMUtils
import "tools.js" as Tools

// Everything inside the popup: header, sidebar, app list, footer.
FocusScope {
    id: content

    required property var lw
    readonly property var cfg: Plasmoid.configuration
    readonly property var rootModel: lw.rootModel
    readonly property var favModel: rootModel ? rootModel.favoritesModel : null
    // 2 = custom colour, 3 = picture: both draw their own background
    readonly property bool customBg: cfg.backgroundStyle >= 2
    readonly property bool sidebarRight: cfg.sidebarOnRight
    // 0 top (with user info), 1 bottom above the footer,
    // 2 in the footer next to the settings button, 3 in the footer next to the power buttons
    readonly property int searchPos: cfg.searchPosition
    readonly property bool searchBelow: searchPos !== 0
    readonly property bool searchInHeader: searchPos <= 1
    readonly property bool showUserInfo: cfg.showUserHeader && (cfg.showAvatar || cfg.showUserName)
    // Power buttons: 0 footer right, 1 footer left, 2 footer centre, 3 top bar, 4 under the categories
    readonly property int powerPos: cfg.powerPosition
    readonly property bool powerShown: cfg.showPowerBar
    // Settings button: 0 footer left, 1 footer right, 2 top bar, 3 under the categories
    readonly property int settingsPos: cfg.settingsPosition
    readonly property bool settingsShown: cfg.showSettingsButton
    readonly property bool headerVisible: searchInHeader || showUserInfo
                                          || (powerShown && powerPos === 3) || (settingsShown && settingsPos === 2)
    readonly property bool footerVisible: lw.updateAvailable || searchPos >= 2
                                          || (powerShown && powerPos <= 2) || (settingsShown && settingsPos <= 1)
    readonly property bool searching: searchField.text.length > 0
    readonly property var powerList: Tools.toArray(cfg.powerButtons)
    readonly property real textScale: Math.max(50, cfg.textScale) / 100

    // -1 = Favourites, 0..n = row in rootModel
    property int sidebarIndex: -1
    property int modelRevision: 0
    property int allAppsRow: -1

    // Fully see-through (no background either) while an app is starting (see main.qml)
    // Size: the saved size, or the live size while an edge is being dragged.
    property real dragW: -1
    property real dragH: -1
    readonly property real baseW: dragW > 0 ? dragW : cfg.menuWidth
    readonly property real baseH: dragH > 0 ? dragH : cfg.menuHeight
    width: baseW
    height: baseH
    opacity: openStyle === 0 ? 1 : Math.min(1, openProgress)

    // ---------------------------------------------------------------- animations
    // Plasma/KWin own the window itself, so these animate what's inside it.
    // 0 none, 1 fade, 2 slide in from the taskbar side, 3 zoom in, 4 unfold
    readonly property int openStyle: cfg.openAnimation
    readonly property bool animsOff: cfg.respectPlasmaSpeed && Kirigami.Units.longDuration <= 1
    property real openProgress: 1
    property bool suppressSwitchAnim: false

    function animMs(ms) {
        return animsOff ? 0 : Math.max(0, ms);
    }
    function easingFor(i) {
        return [Easing.OutCubic, Easing.InOutQuad, Easing.OutBack, Easing.Linear][Math.max(0, Math.min(3, i))];
    }

    // Which way "in from the taskbar" is
    readonly property int panelEdge: Plasmoid.location
    readonly property real slideDistance: Kirigami.Units.gridUnit * 3

    transform: [
        Translate {
            readonly property real t: content.openStyle === 2 ? (1 - content.openProgress) * content.slideDistance : 0
            x: content.panelEdge === PlasmaCore.Types.LeftEdge ? -t : content.panelEdge === PlasmaCore.Types.RightEdge ? t : 0
            y: content.panelEdge === PlasmaCore.Types.TopEdge ? -t
               : (content.panelEdge === PlasmaCore.Types.LeftEdge || content.panelEdge === PlasmaCore.Types.RightEdge) ? 0 : t
        },
        Scale {
            readonly property real z: content.openStyle === 3 ? 0.88 + 0.12 * content.openProgress : 1
            readonly property real u: content.openStyle === 4 ? Math.max(0.02, content.openProgress) : 1
            origin.x: content.width / 2
            origin.y: content.panelEdge === PlasmaCore.Types.TopEdge ? 0
                      : content.openStyle === 4 ? content.height : content.height / 2
            xScale: z
            yScale: z * u
        }
    ]

    NumberAnimation {
        id: openAnim
        target: content
        property: "openProgress"
        to: 1
        duration: content.animMs(content.cfg.openDuration)
        easing.type: content.easingFor(content.cfg.openEasing)
    }
    NumberAnimation {
        id: closeAnim
        target: content
        property: "openProgress"
        to: 0
        duration: content.animMs(content.cfg.openDuration * 0.75)
        easing.type: Easing.InCubic
        onFinished: content.lw.finishClose()
    }

    function playOpen() {
        closeAnim.stop();
        if (openStyle === 0 || animMs(cfg.openDuration) === 0) {
            openProgress = 1;
            return;
        }
        openAnim.from = openProgress < 1 ? openProgress : 0;
        openAnim.restart();
    }
    // Returns false when there's nothing to animate (caller hides at once)
    function playClose() {
        if (openStyle === 0 || !cfg.animateClose || animMs(cfg.openDuration) === 0) {
            return false;
        }
        openAnim.stop();
        closeAnim.from = openProgress;
        closeAnim.restart();
        return true;
    }
    function stopClose() {
        closeAnim.stop();
    }
    // Fixed small minimum: Plasma's popup applies a new size before it lowers
    // the window's minimum, so a minimum tied to the current size blocks shrinking.
    Layout.minimumWidth: 300
    Layout.minimumHeight: 250
    Layout.preferredWidth: width
    Layout.preferredHeight: height

    readonly property var categoryModel: {
        void modelRevision;
        void (rootModel ? rootModel.count : 0);
        if (!rootModel || sidebarIndex < 0 || sidebarIndex >= rootModel.count) {
            return null;
        }
        return rootModel.modelForRow(sidebarIndex);
    }

    readonly property var searchModel: {
        const rm = lw.runnerModel;
        return (rm && rm.count > 0) ? rm.modelForRow(0) : null;
    }

    Connections {
        target: content.rootModel
        ignoreUnknownSignals: true
        function onRefreshed() {
            content.modelRevision++;
            content.allAppsRow = content.findAllAppsRow();
            if (content.sidebarIndex >= content.rootModel.count) {
                content.sidebarIndex = -1;
            }
        }
        function onCountChanged() {
            content.allAppsRow = content.findAllAppsRow();
        }
    }

    KCoreAddons.KUser {
        id: kuser
    }

    // ---------------------------------------------------------------- helpers

    function prepare() {
        suppressSwitchAnim = true;
        closeAnim.stop();
        openAnim.stop();
        // start hidden so the opening animation doesn't flash the full menu first
        openProgress = (openStyle === 0 || animMs(cfg.openDuration) === 0) ? 1 : 0;
        searchField.text = "";
        allAppsRow = findAllAppsRow();
        sidebarIndex = (cfg.startView === 1 && allAppsRow >= 0) ? allAppsRow : -1;
        favView.resetView();
        catView.resetView();
        searchView.resetView();
        viewArea.switchProgress = 1;
        suppressSwitchAnim = false;
    }

    function focusSearch() {
        searchField.forceActiveFocus();
    }

    function clearOrClose() {
        if (searching) {
            searchField.text = "";
            searchField.forceActiveFocus();
        } else {
            lw.closeMenu();
        }
    }

    // "All Applications" is simply the biggest list in the tree.
    function findAllAppsRow() {
        let best = -1, bestCount = -1;
        if (!rootModel) {
            return best;
        }
        for (let i = 0; i < rootModel.count; ++i) {
            const m = rootModel.modelForRow(i);
            if (m && m.count > bestCount) {
                best = i;
                bestCount = m.count;
            }
        }
        return best;
    }

    function currentAppView() {
        if (searching) {
            return searchView;
        }
        return sidebarIndex === -1 ? favView : catView;
    }

    function moveSidebar(delta) {
        const max = rootModel ? rootModel.count - 1 : -1;
        sidebarIndex = Tools.clamp(sidebarIndex + delta, -1, max);
    }

    // Per-category icon overrides, stored as "Name=icon-name"
    function categoryIcon(name, fallback) {
        const list = Tools.toArray(cfg.categoryIcons);
        for (let i = 0; i < list.length; ++i) {
            const p = list[i].indexOf("=");
            if (p > 0 && list[i].substring(0, p) === name) {
                return list[i].substring(p + 1);
            }
        }
        return fallback;
    }
    function hasIconOverride(name) {
        return Tools.toArray(cfg.categoryIcons).some(s => s.startsWith(name + "="));
    }
    function setCategoryIcon(name, icon) {
        const list = Tools.toArray(cfg.categoryIcons).filter(s => !s.startsWith(name + "="));
        if (icon) {
            list.push(name + "=" + icon);
        }
        cfg.categoryIcons = list;
    }
    function pickIcon(key) {
        iconPickerLoader.active = true;
        const p = iconPickerLoader.item;
        if (!p) {
            console.warn("Launchwell: icon picker unavailable");
            return;
        }
        p.targetKey = key;
        p.openPicker();
        // Same as launching an app: vanish now, keep focus until the picker
        // window appears, so it opens on this monitor.
        lw.closeMenuAfterLaunch();
    }

    function openItemMenu(appView, row, data, item, x, y) {
        const src = appView.model;
        if (!src) {
            return;
        }
        const entries = [];
        const fid = data.favoriteId || "";
        const fav = favModel;

        if (fav && fid && typeof fav.isFavorite === "function") {
            const isFav = fav.isFavorite(fid);
            entries.push({
                text: isFav ? i18n("Remove from Favourites") : i18n("Add to Favourites"),
                icon: isFav ? "list-remove" : "bookmark-new",
                run: () => isFav ? fav.removeFavorite(fid) : fav.addFavorite(fid, -1)
            });
        }
        if (appView.isFavourites && fav && typeof fav.moveRow === "function") {
            const grid = appView.gridMode;
            if (row > 0) {
                entries.push({ text: grid ? i18n("Move Left") : i18n("Move Up"),
                               icon: grid ? "go-previous" : "go-up",
                               run: () => fav.moveRow(row, row - 1) });
                entries.push({ text: i18n("Move to Start"), icon: "go-first",
                               run: () => fav.moveRow(row, 0) });
            }
            if (row < src.count - 1) {
                entries.push({ text: grid ? i18n("Move Right") : i18n("Move Down"),
                               icon: grid ? "go-next" : "go-down",
                               run: () => fav.moveRow(row, row + 1) });
            }
        }

        const actions = data.hasActionList ? Tools.toArray(data.actionList) : [];
        for (const a of actions) {
            if (!a || !a.text || a.type === "separator" || a.type === "title") {
                continue;
            }
            if (String(a.actionId || "").startsWith("_kicker_favorite")) {
                continue;   // handled by our own favourite entries above
            }
            entries.push({
                text: a.text,
                icon: typeof a.icon === "string" ? a.icon : "",
                disabled: !!a.disabled,
                run: () => { src.trigger(row, a.actionId, a.actionArgument); lw.closeMenuAfterLaunch(); }
            });
        }
        if (entries.length === 0) {
            return;
        }
        itemMenu.entries = entries;
        itemMenu.popup(item, x, y);
    }

    // Typing anywhere goes to the search box; arrows move between panes.
    Keys.onPressed: (event) => {
        const toSidebar = sidebarRight ? Qt.Key_Right : Qt.Key_Left;
        if (event.key === Qt.Key_Escape) {
            clearOrClose();
            event.accepted = true;
        } else if (event.key === toSidebar && !searching && !sidebar.activeFocus) {
            sidebar.forceActiveFocus();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace && !searchField.activeFocus) {
            searchField.text = searchField.text.slice(0, -1);
            searchField.forceActiveFocus();
            event.accepted = true;
        } else if (event.text.length > 0 && !searchField.activeFocus
                   && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127
                   && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
            searchField.text += event.text;
            searchField.forceActiveFocus();
            event.accepted = true;
        }
    }

    // ---------------------------------------------------------------- custom background

    Rectangle {
        anchors.fill: parent
        visible: content.cfg.backgroundStyle === 2
        color: content.cfg.customBgColor
        opacity: content.cfg.customBgOpacity / 100
        radius: content.cfg.cornerRadius
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)
    }

    Loader {
        anchors.fill: parent
        active: content.cfg.backgroundStyle === 3
        source: "PictureBackground.qml"
    }

    // ---------------------------------------------------------------- layout

    // A one-column grid so the header (with search) can sit above or below the app area.
    GridLayout {
        anchors.fill: parent
        anchors.margins: content.customBg ? Kirigami.Units.largeSpacing : 0
        columns: 1
        rowSpacing: Kirigami.Units.smallSpacing

        // Header: avatar, name, (search)
        RowLayout {
            Layout.row: content.searchPos === 1 ? 2 : 0
            visible: content.headerVisible
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.largeSpacing

            Item {
                id: avatar
                visible: content.cfg.showUserHeader && content.cfg.showAvatar
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                readonly property string face: kuser.faceIconUrl ? kuser.faceIconUrl.toString() : ""

                Kirigami.Icon {
                    anchors.fill: parent
                    visible: avatar.face.length === 0
                    source: "user-identity"
                }
                Kirigami.ShadowedImage {
                    anchors.fill: parent
                    visible: avatar.face.length > 0
                    source: avatar.face
                    radius: width / 2
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(width * 2, height * 2)
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        KCMUtils.KCMLauncher.openSystemSettings("kcm_users");
                        content.lw.closeMenuAfterLaunch();
                    }
                }
            }

            PC3.Label {
                visible: content.cfg.showUserHeader && content.cfg.showUserName
                text: kuser.fullName || kuser.loginName
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.15 * content.textScale
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                Layout.maximumWidth: content.width * 0.35
            }

            // Search box lives here when it is in the header
            Item {
                id: headerSearchSlot
                visible: content.searchInHeader
                Layout.fillWidth: true
                Layout.preferredHeight: searchField.implicitHeight
            }
            Item {
                visible: !content.searchInHeader
                Layout.fillWidth: true
            }
            Item {
                id: headerPowerSlot
                visible: content.powerShown && content.powerPos === 3
                Layout.preferredWidth: powerBar.implicitWidth
                Layout.preferredHeight: powerBar.implicitHeight
            }
            Item {
                id: headerSettingsSlot
                visible: content.settingsShown && content.settingsPos === 2
                Layout.preferredWidth: settingsButton.implicitWidth
                Layout.preferredHeight: settingsButton.implicitHeight
            }
        }

        Kirigami.Separator {
            Layout.row: 1
            Layout.fillWidth: true
            visible: content.headerVisible
        }

        // Body: sidebar + contents
        RowLayout {
            Layout.row: content.searchPos === 1 ? 0 : 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            layoutDirection: content.sidebarRight ? Qt.RightToLeft : Qt.LeftToRight

            FocusScope {
                id: sidebar
                visible: !content.searching
                Layout.preferredWidth: content.cfg.sidebarWidth
                Layout.fillHeight: true

                Keys.onUpPressed: content.moveSidebar(-1)
                Keys.onDownPressed: content.moveSidebar(1)
                Keys.onReturnPressed: content.currentAppView().focusFirst()
                Keys.onEnterPressed: content.currentAppView().focusFirst()
                Keys.onPressed: (event) => {
                    if (event.key === (content.sidebarRight ? Qt.Key_Left : Qt.Key_Right)) {
                        content.currentAppView().focusFirst();
                        event.accepted = true;
                    }
                }

                // Settings / power buttons can sit under the category list
                RowLayout {
                    id: sidebarBottom
                    readonly property bool used: (content.settingsShown && content.settingsPos === 3)
                                                 || (content.powerShown && content.powerPos === 4)
                    visible: used
                    height: used ? implicitHeight : 0
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: Kirigami.Units.smallSpacing
                    spacing: Kirigami.Units.smallSpacing

                    Item {
                        id: sidebarSettingsSlot
                        visible: content.settingsShown && content.settingsPos === 3
                        Layout.preferredWidth: settingsButton.implicitWidth
                        Layout.preferredHeight: settingsButton.implicitHeight
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Item {
                        id: sidebarPowerSlot
                        visible: content.powerShown && content.powerPos === 4
                        Layout.preferredWidth: powerBar.implicitWidth
                        Layout.preferredHeight: powerBar.implicitHeight
                    }
                }

                QQC2.ScrollView {
                    id: sidebarScroll
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: sidebarBottom.used ? sidebarBottom.top : parent.bottom
                    anchors.margins: Kirigami.Units.smallSpacing
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

                    Column {
                        width: sidebarScroll.availableWidth
                        spacing: 0

                        SidebarItem {
                            width: parent.width
                            text: i18n("Favourites")
                            iconSource: content.categoryIcon("__favourites__", "favorite")
                            classicAllowed: !content.hasIconOverride("__favourites__")
                            selected: content.sidebarIndex === -1
                            keyboardFocus: sidebar.activeFocus
                            onActivate: content.sidebarIndex = -1
                            onContextRequested: (x, y) => catMenu.openFor("__favourites__", this, x, y)
                        }

                        Repeater {
                            model: content.rootModel
                            delegate: SidebarItem {
                                required property int index
                                required property var model
                                readonly property string name: model.display || ""
                                width: parent ? parent.width : 0
                                visible: !model.isSeparator
                                text: name
                                iconSource: content.categoryIcon(name, model.decoration)
                                classicAllowed: !content.hasIconOverride(name)
                                selected: content.sidebarIndex === index
                                keyboardFocus: sidebar.activeFocus
                                onActivate: content.sidebarIndex = index
                                onContextRequested: (x, y) => catMenu.openFor(name, this, x, y)
                            }
                        }
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillHeight: true
                visible: sidebar.visible
            }

            Item {
                id: viewArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: content.cfg.switchAnimation >= 2

                // 0 none, 1 fade, 2 slide sideways, 3 slide up
                property real switchProgress: 1
                readonly property int switchStyle: content.cfg.switchAnimation
                opacity: switchStyle === 0 ? 1 : switchProgress
                transform: Translate {
                    x: viewArea.switchStyle === 2 ? (1 - viewArea.switchProgress) * Kirigami.Units.gridUnit * 2 : 0
                    y: viewArea.switchStyle === 3 ? (1 - viewArea.switchProgress) * Kirigami.Units.gridUnit * 2 : 0
                }
                NumberAnimation {
                    id: switchAnim
                    target: viewArea
                    property: "switchProgress"
                    from: 0
                    to: 1
                    duration: content.animMs(content.cfg.switchDuration)
                    easing.type: Easing.OutCubic
                }
                function play() {
                    if (switchStyle === 0 || content.suppressSwitchAnim || content.animMs(content.cfg.switchDuration) === 0) {
                        switchProgress = 1;
                        return;
                    }
                    switchAnim.restart();
                }
                Connections {
                    target: content
                    function onSidebarIndexChanged() { viewArea.play(); }
                    function onSearchingChanged() { viewArea.play(); }
                }

                AppView {
                    id: favView
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    visible: !content.searching && content.sidebarIndex === -1
                    model: content.favModel
                    isFavourites: true
                    gridMode: content.cfg.favouritesView === 1
                    emptyText: i18n("No favourites yet.\nRight-click any app and choose \"Add to Favourites\".")
                    emptyIcon: "favorite"
                    onLaunched: content.lw.closeMenuAfterLaunch()
                    onLeaveTop: content.focusSearch()
                    onContextMenuRequested: (row, data, item, x, y) => content.openItemMenu(favView, row, data, item, x, y)
                }

                AppView {
                    id: catView
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    visible: !content.searching && content.sidebarIndex >= 0
                    model: content.categoryModel
                    gridMode: content.cfg.appsView === 1
                    showSections: !gridMode && (content.cfg.showLetterHeaders === 2
                                  || (content.cfg.showLetterHeaders === 1 && content.sidebarIndex === content.allAppsRow))
                    onLaunched: content.lw.closeMenuAfterLaunch()
                    onLeaveTop: content.focusSearch()
                    onContextMenuRequested: (row, data, item, x, y) => content.openItemMenu(catView, row, data, item, x, y)
                }

                AppView {
                    id: searchView
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    visible: content.searching
                    model: content.searchModel
                    autoSelectFirst: true
                    emptyText: content.searching ? i18n("No matches") : ""
                    emptyIcon: "edit-none"
                    onLaunched: content.lw.closeMenuAfterLaunch()
                    onLeaveTop: content.focusSearch()
                    onContextMenuRequested: (row, data, item, x, y) => content.openItemMenu(searchView, row, data, item, x, y)
                }
            }
        }

        Kirigami.Separator {
            Layout.row: 3
            Layout.fillWidth: true
            visible: content.footerVisible
        }

        // Footer: settings + power buttons
        RowLayout {
            id: footer
            Layout.row: 4
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.smallSpacing
            visible: content.footerVisible
            spacing: Kirigami.Units.smallSpacing

            Item {
                id: footerSettingsLeft
                visible: content.settingsShown && content.settingsPos === 0
                Layout.preferredWidth: settingsButton.implicitWidth
                Layout.preferredHeight: settingsButton.implicitHeight
            }
            // "Update available" button, when a newer release is out
            PC3.ToolButton {
                id: updateButton
                visible: content.lw.updateAvailable
                icon.name: "system-software-update"
                text: i18n("Update %1", content.lw.updateVersion)
                PC3.ToolTip.text: i18n("Launchwell %1 is available. Click to open the download page; right-click for options.", content.lw.updateVersion)
                PC3.ToolTip.visible: hovered
                PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
                onClicked: content.lw.openUpdatePage()
                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: updateMenu.popup(updateButton, updateButton.width / 2, updateButton.height / 2)
                }
            }

            Item {
                id: footerPowerLeft
                visible: content.powerShown && content.powerPos === 1
                Layout.preferredWidth: powerBar.implicitWidth
                Layout.preferredHeight: powerBar.implicitHeight
            }

            Item {
                id: footerSearchSlotLeft
                visible: content.searchPos === 2
                Layout.preferredWidth: content.width * Math.max(20, content.cfg.searchWidth) / 100
                Layout.preferredHeight: searchField.implicitHeight
            }

            Item {
                Layout.fillWidth: true
            }
            Item {
                id: footerPowerCentre
                visible: content.powerShown && content.powerPos === 2
                Layout.preferredWidth: powerBar.implicitWidth
                Layout.preferredHeight: powerBar.implicitHeight
            }
            Item {
                visible: content.powerShown && content.powerPos === 2
                Layout.fillWidth: true
            }

            Item {
                id: footerSearchSlotRight
                visible: content.searchPos === 3
                Layout.preferredWidth: content.width * Math.max(20, content.cfg.searchWidth) / 100
                Layout.preferredHeight: searchField.implicitHeight
            }

            Item {
                id: footerPowerRight
                visible: content.powerShown && content.powerPos === 0
                Layout.preferredWidth: powerBar.implicitWidth
                Layout.preferredHeight: powerBar.implicitHeight
            }
            Item {
                id: footerSettingsRight
                visible: content.settingsShown && content.settingsPos === 1
                Layout.preferredWidth: settingsButton.implicitWidth
                Layout.preferredHeight: settingsButton.implicitHeight
            }
        }
    }

    // ---------------------------------------------------------------- drag to resize

    ResizeHandles {
        menu: content
        lw: content.lw
    }

    // ---------------------------------------------------------------- settings + power buttons

    // The settings (cog) button, placed into its chosen slot
    PC3.ToolButton {
        id: settingsButton
        parent: content.settingsPos === 1 ? footerSettingsRight
              : content.settingsPos === 2 ? headerSettingsSlot
              : content.settingsPos === 3 ? sidebarSettingsSlot
              : footerSettingsLeft
        anchors.centerIn: parent
        visible: content.settingsShown
        icon.name: "configure"
        PC3.ToolTip.text: i18n("Configure Launchwell…")
        PC3.ToolTip.visible: hovered
        PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
        onClicked: {
            const a = Plasmoid.internalAction("configure");
            if (a) {
                a.trigger();
            }
            // vanish now, keep focus until the settings window appears (same monitor)
            content.lw.closeMenuAfterLaunch();
        }
    }

    // The power buttons, as one row that can be placed in any of the slots
    RowLayout {
        id: powerBar
        parent: content.powerPos === 1 ? footerPowerLeft
              : content.powerPos === 2 ? footerPowerCentre
              : content.powerPos === 3 ? headerPowerSlot
              : content.powerPos === 4 ? sidebarPowerSlot
              : footerPowerRight
        anchors.centerIn: parent
        visible: content.powerShown
        spacing: Kirigami.Units.smallSpacing

        Repeater {
            model: content.lw.systemModel

            delegate: PC3.ToolButton {
                id: pb
                required property int index
                required property var model
                readonly property string fid: model.favoriteId || ""
                visible: !model.isSeparator && content.powerList.indexOf(fid) !== -1
                text: model.display || ""
                PC3.ToolTip.text: text
                PC3.ToolTip.visible: hovered && !(content.cfg.powerButtonText && content.powerPos !== 4)
                PC3.ToolTip.delay: Kirigami.Units.toolTipDelay

                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    IconBox {
                        Layout.alignment: Qt.AlignVCenter
                        source: pb.model.decoration
                        size: Kirigami.Units.iconSizes.smallMedium
                        mono: content.cfg.appIconStyle === 1
                        forceColour: content.cfg.forceColour
                    }
                    PC3.Label {
                        visible: content.cfg.powerButtonText && content.powerPos !== 4
                        text: pb.text
                    }
                }

                onClicked: {
                    content.lw.systemModel.trigger(index, "", null);
                    content.lw.closeMenu();
                }
            }
        }
    }

    // ---------------------------------------------------------------- search box

    PlasmaExtras.SearchField {
        id: searchField
        parent: content.searchPos === 2 ? footerSearchSlotLeft
              : content.searchPos === 3 ? footerSearchSlotRight
              : headerSearchSlot
        anchors.fill: parent
        focus: true
        onTextChanged: content.lw.searchText = text
        Keys.onDownPressed: if (!content.searchBelow) content.currentAppView().focusFirst()
        Keys.onUpPressed: if (content.searchBelow) content.currentAppView().focusFirst()
        Keys.onReturnPressed: content.currentAppView().triggerCurrentOrFirst()
        Keys.onEnterPressed: content.currentAppView().triggerCurrentOrFirst()
        Keys.onEscapePressed: content.clearOrClose()
    }

    // ---------------------------------------------------------------- menus

    PC3.Menu {
        id: itemMenu
        property var entries: []

        Instantiator {
            model: itemMenu.entries
            delegate: PC3.MenuItem {
                required property var modelData
                text: modelData.text
                icon.name: modelData.icon || ""
                enabled: !modelData.disabled
                onTriggered: modelData.run()
            }
            onObjectAdded: (index, object) => itemMenu.insertItem(index, object)
            onObjectRemoved: (index, object) => itemMenu.removeItem(object)
        }
    }

    PC3.Menu {
        id: updateMenu
        PC3.MenuItem {
            text: i18n("Open download page")
            icon.name: "internet-services"
            onTriggered: content.lw.openUpdatePage()
        }
        PC3.MenuItem {
            text: i18n("Skip this version")
            icon.name: "dialog-cancel"
            onTriggered: content.cfg.skippedVersion = content.lw.updateVersion
        }
    }

    PC3.Menu {
        id: catMenu
        property string key: ""

        function openFor(k, item, x, y) {
            key = k;
            popup(item, x, y);
        }

        PC3.MenuItem {
            text: i18n("Choose Icon…")
            icon.name: "document-edit"
            onTriggered: content.pickIcon(catMenu.key)
        }
        PC3.MenuItem {
            text: i18n("Reset Icon")
            icon.name: "edit-undo"
            enabled: content.hasIconOverride(catMenu.key)
            onTriggered: content.setCategoryIcon(catMenu.key, "")
        }
    }

    Loader {
        id: iconPickerLoader
        active: false
        source: "IconPicker.qml"
    }
    Connections {
        target: iconPickerLoader.item
        ignoreUnknownSignals: true
        function onPicked(key, icon) {
            content.setCategoryIcon(key, icon);
        }
    }
}
