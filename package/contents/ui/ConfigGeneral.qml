/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.iconthemes as KIconThemes
import "tools.js" as Tools

KCM.SimpleKCM {
    id: page

    property alias cfg_icon: iconField.text
    property alias cfg_buttonIconMono: buttonMono.checked
    property alias cfg_buttonIconStyle: buttonStyle.currentIndex
    property alias cfg_menuLabel: labelField.text
    property alias cfg_showUserHeader: showHeader.checked
    property alias cfg_showAvatar: showAvatar.checked
    property alias cfg_showUserName: showName.checked
    property alias cfg_startView: startView.currentIndex
    property alias cfg_switchOnHover: hoverSwitch.checked
    property alias cfg_alphaSort: alphaSort.checked
    property alias cfg_appNameFormat: nameFormat.currentIndex
    property alias cfg_showDescriptions: showDesc.checked
    property alias cfg_showLetterHeaders: letterHeaders.currentIndex
    property alias cfg_showRecentApps: recentApps.checked
    property alias cfg_showRecentDocs: recentDocs.checked
    property alias cfg_extendedSearch: extSearch.checked
    property alias cfg_favouritesView: favView.currentIndex
    property alias cfg_appsView: appsView.currentIndex
    property alias cfg_sidebarOnRight: sidebarRight.checked
    property alias cfg_searchPosition: searchPos.currentIndex
    property alias cfg_searchWidth: searchWidth.value
    property alias cfg_showPowerBar: showPower.checked
    property alias cfg_powerButtonText: powerText.checked
    property alias cfg_showSettingsButton: settingsBtn.checked
    property alias cfg_checkUpdates: checkUpdates.checked
    property string cfg_skippedVersion: ""
    property alias cfg_powerPosition: powerPos.currentIndex
    property alias cfg_settingsPosition: settingsPos.currentIndex
    property var cfg_powerButtons: []

    // --- Declared so Plasma does not log "does not have a property" warnings.
    // --- Settings that live on other pages; not used here.
    property var cfg_iconDefault
    property var cfg_buttonIconStyleDefault
    property var cfg_buttonIconMonoDefault
    property var cfg_menuLabelDefault
    property var cfg_showUserHeaderDefault
    property var cfg_showAvatarDefault
    property var cfg_showUserNameDefault
    property var cfg_startViewDefault
    property var cfg_switchOnHoverDefault
    property var cfg_alphaSortDefault
    property var cfg_appNameFormatDefault
    property var cfg_showDescriptionsDefault
    property var cfg_showLetterHeadersDefault
    property var cfg_showRecentAppsDefault
    property var cfg_showRecentDocsDefault
    property var cfg_extendedSearchDefault
    property var cfg_favouritesViewDefault
    property var cfg_appsViewDefault
    property var cfg_sidebarOnRightDefault
    property var cfg_searchPositionDefault
    property var cfg_searchWidthDefault
    property var cfg_showPowerBarDefault
    property var cfg_powerButtonsDefault
    property var cfg_powerButtonTextDefault
    property var cfg_powerPositionDefault
    property var cfg_settingsPositionDefault
    property var cfg_showSettingsButtonDefault
    property var cfg_checkUpdatesDefault
    property var cfg_skippedVersionDefault
    property var cfg_categoryIcons
    property var cfg_categoryIconsDefault
    property var cfg_favouritesSeeded
    property var cfg_favouritesSeededDefault
    property var cfg_categoryIconStyle
    property var cfg_categoryIconStyleDefault
    property var cfg_appIconStyle
    property var cfg_appIconStyleDefault
    property var cfg_forceColour
    property var cfg_forceColourDefault
    property var cfg_categoryIconSize
    property var cfg_categoryIconSizeDefault
    property var cfg_appIconSize
    property var cfg_appIconSizeDefault
    property var cfg_gridIconSize
    property var cfg_gridIconSizeDefault
    property var cfg_sidebarWidth
    property var cfg_sidebarWidthDefault
    property var cfg_rowSpacing
    property var cfg_rowSpacingDefault
    property var cfg_textScale
    property var cfg_textScaleDefault
    property var cfg_backgroundStyle
    property var cfg_backgroundStyleDefault
    property var cfg_customBgColor
    property var cfg_customBgColorDefault
    property var cfg_customBgOpacity
    property var cfg_customBgOpacityDefault
    property var cfg_cornerRadius
    property var cfg_cornerRadiusDefault
    property var cfg_newAppBadge
    property var cfg_newAppBadgeDefault
    property var cfg_newBadgeShape
    property var cfg_newBadgeShapeDefault
    property var cfg_newBadgeColorMode
    property var cfg_newBadgeColorModeDefault
    property var cfg_newBadgeColor
    property var cfg_newBadgeColorDefault
    property var cfg_newBadgeSize
    property var cfg_newBadgeSizeDefault
    property var cfg_customBgImage
    property var cfg_customBgImageDefault
    property var cfg_bgImageFill
    property var cfg_bgImageFillDefault
    property var cfg_bgImageBlur
    property var cfg_bgImageBlurDefault
    property var cfg_bgImageDim
    property var cfg_bgImageDimDefault
    property var cfg_openAnimation
    property var cfg_openAnimationDefault
    property var cfg_openDuration
    property var cfg_openDurationDefault
    property var cfg_openEasing
    property var cfg_openEasingDefault
    property var cfg_animateClose
    property var cfg_animateCloseDefault
    property var cfg_switchAnimation
    property var cfg_switchAnimationDefault
    property var cfg_switchDuration
    property var cfg_switchDurationDefault
    property var cfg_cascadeItems
    property var cfg_cascadeItemsDefault
    property var cfg_cascadeDelay
    property var cfg_cascadeDelayDefault
    property var cfg_smoothHover
    property var cfg_smoothHoverDefault
    property var cfg_hoverDuration
    property var cfg_hoverDurationDefault
    property var cfg_respectPlasmaSpeed
    property var cfg_respectPlasmaSpeedDefault
    property var cfg_menuWidth
    property var cfg_menuWidthDefault
    property var cfg_menuHeight
    property var cfg_menuHeightDefault
    property var cfg_dragResize
    property var cfg_dragResizeDefault
    property var cfg_horizontalPosition
    property var cfg_horizontalPositionDefault
    property var cfg_horizontalOffset
    property var cfg_horizontalOffsetDefault
    property var cfg_verticalPosition
    property var cfg_verticalPositionDefault
    property var cfg_verticalGap
    property var cfg_verticalGapDefault
    property var cfg_verticalOffset
    property var cfg_verticalOffsetDefault
    property var cfg_keepOnScreen
    property var cfg_keepOnScreenDefault
    property var cfg_windowType
    property var cfg_windowTypeDefault
    // --- end




























    readonly property var powerChoices: [
        { id: "lock-screen", label: i18n("Lock") },
        { id: "logout",      label: i18n("Log Out") },
        { id: "switch-user", label: i18n("Switch User") },
        { id: "suspend",     label: i18n("Sleep") },
        { id: "hibernate",   label: i18n("Hibernate") },
        { id: "reboot",      label: i18n("Restart") },
        { id: "shutdown",    label: i18n("Shut Down") }
    ]

    KIconThemes.IconDialog {
        id: iconDialog
        onIconNameChanged: if (iconName) iconField.text = iconName
    }

    Kirigami.FormLayout {
        // ------------------------------------------------ panel button
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Panel button") }

        RowLayout {
            Kirigami.FormData.label: i18n("Icon:")
            QQC2.ComboBox {
                id: buttonStyle
                model: [i18n("Classic Colour"),
                        i18n("New Symbolic"),
                        i18n("Custom icon")]
            }
            IconBox {
                size: Kirigami.Units.iconSizes.medium
                source: buttonStyle.currentIndex === 2 ? (iconField.text || "start-here-kde") : "start-here-kde"
                classic: buttonStyle.currentIndex === 0
                mono: buttonStyle.currentIndex === 1 || (buttonStyle.currentIndex === 2 && buttonMono.checked)
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Custom icon:")
            enabled: buttonStyle.currentIndex === 2
            QQC2.TextField {
                id: iconField
                Layout.preferredWidth: Kirigami.Units.gridUnit * 12
                placeholderText: "start-here-kde"
            }
            QQC2.Button {
                icon.name: "document-open"
                text: i18n("Choose…")
                onClicked: iconDialog.open()
            }
        }
        QQC2.CheckBox {
            id: buttonMono
            enabled: buttonStyle.currentIndex === 2
            text: i18n("Draw the custom icon in mono")
        }
        QQC2.TextField {
            id: labelField
            Kirigami.FormData.label: i18n("Text label:")
            placeholderText: i18n("None (icon only)")
        }

        // ------------------------------------------------ header & layout
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Layout") }

        QQC2.CheckBox { id: showHeader; Kirigami.FormData.label: i18n("Header:"); text: i18n("Show user info") }
        QQC2.CheckBox { id: showAvatar; text: i18n("Show avatar"); enabled: showHeader.checked }
        QQC2.CheckBox { id: showName; text: i18n("Show name"); enabled: showHeader.checked }
        QQC2.CheckBox { id: sidebarRight; Kirigami.FormData.label: i18n("Categories:"); text: i18n("Put the category list on the right") }
        QQC2.ComboBox {
            id: searchPos
            Kirigami.FormData.label: i18n("Search bar:")
            model: [i18n("Top, with your name and picture"),
                    i18n("Bottom, above the footer"),
                    i18n("In the footer, next to the settings button"),
                    i18n("In the footer, next to the power buttons")]
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Search bar width:")
            enabled: searchPos.currentIndex >= 2
            QQC2.SpinBox { id: searchWidth; from: 20; to: 80; stepSize: 5 }
            QQC2.Label { text: i18n("% of the menu (when in the footer)") }
        }

        QQC2.ComboBox {
            id: favView
            Kirigami.FormData.label: i18n("Favourites shown as:")
            model: [i18n("List"), i18n("Grid")]
        }
        QQC2.ComboBox {
            id: appsView
            Kirigami.FormData.label: i18n("Applications shown as:")
            model: [i18n("List"), i18n("Grid")]
        }

        // ------------------------------------------------ behaviour
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Behaviour") }

        QQC2.ComboBox {
            id: startView
            Kirigami.FormData.label: i18n("Open on:")
            model: [i18n("Favourites"), i18n("All Applications")]
        }
        QQC2.CheckBox { id: hoverSwitch; text: i18n("Switch categories on hover") }
        QQC2.CheckBox { id: alphaSort; text: i18n("Sort applications alphabetically") }

        QQC2.ComboBox {
            id: nameFormat
            Kirigami.FormData.label: i18n("Show applications as:")
            model: [i18n("Name only"), i18n("Description only"), i18n("Name (Description)"), i18n("Description (Name)")]
        }
        QQC2.CheckBox { id: showDesc; text: i18n("Show a description line under each app") }
        QQC2.ComboBox {
            id: letterHeaders
            Kirigami.FormData.label: i18n("Letter headings (A, B, C…):")
            model: [i18n("Never"), i18n("In All Applications"), i18n("In every list")]
        }
        QQC2.CheckBox { id: recentApps; Kirigami.FormData.label: i18n("Extra categories:"); text: i18n("Recent applications") }
        QQC2.CheckBox { id: recentDocs; text: i18n("Recent files") }
        QQC2.CheckBox {
            id: extSearch
            Kirigami.FormData.label: i18n("Search:")
            text: i18n("Use all KRunner plugins (files, web shortcuts…)")
        }

        // ------------------------------------------------ footer
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Footer") }

        QQC2.CheckBox { id: settingsBtn; text: i18n("Show settings button") }
        QQC2.ComboBox {
            id: settingsPos
            Kirigami.FormData.label: i18n("Settings button:")
            enabled: settingsBtn.checked
            model: [i18n("Bottom bar, left"), i18n("Bottom bar, right"),
                    i18n("Top bar, right"), i18n("Under the category list")]
        }
        QQC2.CheckBox { id: showPower; text: i18n("Show power buttons") }
        QQC2.ComboBox {
            id: powerPos
            Kirigami.FormData.label: i18n("Power/Session buttons:")
            enabled: showPower.checked
            model: [i18n("Bottom bar, right"), i18n("Bottom bar, left"), i18n("Bottom bar, centre"),
                    i18n("Top bar, right"), i18n("Under the category list")]
        }
        QQC2.CheckBox { id: powerText; text: i18n("Show text on power buttons"); enabled: showPower.checked }
        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            text: i18n("Buttons under the category list are icon-only (text won't fit) and are hidden while you search, because the category list is too.")
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Buttons:")
            enabled: showPower.checked
            Repeater {
                model: page.powerChoices
                delegate: QQC2.CheckBox {
                    required property var modelData
                    text: modelData.label
                    checked: Tools.toArray(page.cfg_powerButtons).indexOf(modelData.id) !== -1
                    onToggled: {
                        // Keep the list in the standard order
                        const current = Tools.toArray(page.cfg_powerButtons);
                        const list = [];
                        for (const c of page.powerChoices) {
                            const on = c.id === modelData.id ? checked : current.indexOf(c.id) !== -1;
                            if (on) {
                                list.push(c.id);
                            }
                        }
                        page.cfg_powerButtons = list;
                    }
                }
            }
        }

        // ------------------------------------------------ updates
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Updates") }

        QQC2.CheckBox {
            id: checkUpdates
            Kirigami.FormData.label: i18n("New versions:")
            text: i18n("Tell me when a new version of Launchwell is out")
            enabled: Tools.updateRepo.length > 0
        }
        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            text: Tools.updateRepo.length > 0
                  ? i18n("Checks github.com/%1 once a day and shows an Update button in the menu when there's a newer release. Nothing is downloaded or installed automatically. You're running version %2.", Tools.updateRepo, Tools.version)
                  : i18n("This copy of Launchwell has no update address set. You're running version %1.", Tools.version)
        }
        QQC2.Button {
            visible: page.cfg_skippedVersion.length > 0
            text: i18n("Stop skipping version %1", page.cfg_skippedVersion)
            icon.name: "edit-undo"
            onClicked: page.cfg_skippedVersion = ""
        }

        // ------------------------------------------------ about
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("About") }

        QQC2.Label {
            Kirigami.FormData.label: i18n("Launchwell:")
            text: i18n("Version %1, © 2026 bobwellapps", Tools.version)
        }
        QQC2.Label {
            Kirigami.FormData.label: i18n("Licence:")
            text: i18n("GNU GPL v2 or later")
        }
        Kirigami.UrlButton {
            Kirigami.FormData.label: i18n("Website:")
            url: "https://github.com/bobwellapps/launchwell"
        }
        QQC2.Label {
            Kirigami.FormData.label: i18n("Disclaimer:")
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.8
            text: i18n("Launchwell is provided \"as is\", without warranty of any kind. You use it at your own risk, and the author accepts no liability for any problems, damage or data loss arising from its use. If anything goes wrong you can remove it and switch back to Plasma's standard launcher at any time.")
        }
    }
}
