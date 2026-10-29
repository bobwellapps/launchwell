/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_openAnimation: openStyle.currentIndex
    property alias cfg_openDuration: openDuration.value
    property alias cfg_openEasing: openEasing.currentIndex
    property alias cfg_animateClose: animateClose.checked
    property alias cfg_switchAnimation: switchStyle.currentIndex
    property alias cfg_switchDuration: switchDuration.value
    property alias cfg_cascadeItems: cascade.checked
    property alias cfg_cascadeDelay: cascadeDelay.value
    property alias cfg_smoothHover: smoothHover.checked
    property alias cfg_hoverDuration: hoverDuration.value
    property alias cfg_respectPlasmaSpeed: respectSpeed.checked

    // --- Declared so Plasma does not log "does not have a property" warnings.
    // --- Settings that live on other pages; not used here.
    property var cfg_icon
    property var cfg_iconDefault
    property var cfg_buttonIconStyle
    property var cfg_buttonIconStyleDefault
    property var cfg_buttonIconMono
    property var cfg_buttonIconMonoDefault
    property var cfg_menuLabel
    property var cfg_menuLabelDefault
    property var cfg_showUserHeader
    property var cfg_showUserHeaderDefault
    property var cfg_showAvatar
    property var cfg_showAvatarDefault
    property var cfg_showUserName
    property var cfg_showUserNameDefault
    property var cfg_startView
    property var cfg_startViewDefault
    property var cfg_switchOnHover
    property var cfg_switchOnHoverDefault
    property var cfg_alphaSort
    property var cfg_alphaSortDefault
    property var cfg_appNameFormat
    property var cfg_appNameFormatDefault
    property var cfg_showDescriptions
    property var cfg_showDescriptionsDefault
    property var cfg_showLetterHeaders
    property var cfg_showLetterHeadersDefault
    property var cfg_showRecentApps
    property var cfg_showRecentAppsDefault
    property var cfg_showRecentDocs
    property var cfg_showRecentDocsDefault
    property var cfg_extendedSearch
    property var cfg_extendedSearchDefault
    property var cfg_favouritesView
    property var cfg_favouritesViewDefault
    property var cfg_appsView
    property var cfg_appsViewDefault
    property var cfg_sidebarOnRight
    property var cfg_sidebarOnRightDefault
    property var cfg_searchPosition
    property var cfg_searchPositionDefault
    property var cfg_searchWidth
    property var cfg_searchWidthDefault
    property var cfg_showPowerBar
    property var cfg_showPowerBarDefault
    property var cfg_powerButtons
    property var cfg_powerButtonsDefault
    property var cfg_powerButtonText
    property var cfg_powerButtonTextDefault
    property var cfg_powerPosition
    property var cfg_powerPositionDefault
    property var cfg_settingsPosition
    property var cfg_settingsPositionDefault
    property var cfg_showSettingsButton
    property var cfg_showSettingsButtonDefault
    property var cfg_checkUpdates
    property var cfg_checkUpdatesDefault
    property var cfg_skippedVersion
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
    property var cfg_customBgImage
    property var cfg_customBgImageDefault
    property var cfg_bgImageFill
    property var cfg_bgImageFillDefault
    property var cfg_bgImageBlur
    property var cfg_bgImageBlurDefault
    property var cfg_bgImageDim
    property var cfg_bgImageDimDefault
    property var cfg_openAnimationDefault
    property var cfg_openDurationDefault
    property var cfg_openEasingDefault
    property var cfg_animateCloseDefault
    property var cfg_switchAnimationDefault
    property var cfg_switchDurationDefault
    property var cfg_cascadeItemsDefault
    property var cfg_cascadeDelayDefault
    property var cfg_smoothHoverDefault
    property var cfg_hoverDurationDefault
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






    Kirigami.FormLayout {
        // ------------------------------------------------ opening
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Opening and closing") }

        QQC2.ComboBox {
            id: openStyle
            Kirigami.FormData.label: i18n("Menu appears with:")
            model: [i18n("No animation"), i18n("Fade in"), i18n("Slide in from the taskbar"),
                    i18n("Zoom in"), i18n("Unfold from the taskbar")]
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Speed:")
            enabled: openStyle.currentIndex > 0
            QQC2.Slider { id: openDuration; from: 60; to: 800; stepSize: 10; Layout.preferredWidth: Kirigami.Units.gridUnit * 10 }
            QQC2.Label { text: i18n("%1 ms", openDuration.value) }
        }
        QQC2.ComboBox {
            id: openEasing
            Kirigami.FormData.label: i18n("Feel:")
            enabled: openStyle.currentIndex > 0
            model: [i18n("Smooth"), i18n("Gentle"), i18n("Bouncy"), i18n("Linear")]
        }
        QQC2.CheckBox {
            id: animateClose
            enabled: openStyle.currentIndex > 0
            text: i18n("Play it in reverse when closing")
        }
        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            text: i18n("The menu's window is placed by Plasma, so the contents animate inside it. Clicking outside the menu, or launching an app, still closes it straight away.")
        }

        // ------------------------------------------------ inside the menu
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Inside the menu") }

        QQC2.ComboBox {
            id: switchStyle
            Kirigami.FormData.label: i18n("Changing category:")
            model: [i18n("No animation"), i18n("Fade"), i18n("Slide sideways"), i18n("Slide up")]
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Speed:")
            enabled: switchStyle.currentIndex > 0
            QQC2.Slider { id: switchDuration; from: 40; to: 600; stepSize: 10; Layout.preferredWidth: Kirigami.Units.gridUnit * 10 }
            QQC2.Label { text: i18n("%1 ms", switchDuration.value) }
        }
        QQC2.CheckBox {
            id: cascade
            Kirigami.FormData.label: i18n("App lists:")
            text: i18n("Fade apps in one after another")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Delay between apps:")
            enabled: cascade.checked
            QQC2.Slider { id: cascadeDelay; from: 5; to: 60; stepSize: 1; Layout.preferredWidth: Kirigami.Units.gridUnit * 10 }
            QQC2.Label { text: i18n("%1 ms", cascadeDelay.value) }
        }
        QQC2.CheckBox {
            id: smoothHover
            Kirigami.FormData.label: i18n("Highlights:")
            text: i18n("Fade the highlight under the mouse")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Highlight speed:")
            enabled: smoothHover.checked
            QQC2.Slider { id: hoverDuration; from: 30; to: 400; stepSize: 10; Layout.preferredWidth: Kirigami.Units.gridUnit * 10 }
            QQC2.Label { text: i18n("%1 ms", hoverDuration.value) }
        }

        // ------------------------------------------------ global
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("System") }

        QQC2.CheckBox {
            id: respectSpeed
            text: i18n("Turn all of these off when Plasma's animation speed is set to Instant")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Presets:")
            QQC2.Button {
                text: i18n("Off")
                onClicked: { openStyle.currentIndex = 0; switchStyle.currentIndex = 0; cascade.checked = false; smoothHover.checked = false }
            }
            QQC2.Button {
                text: i18n("Subtle")
                onClicked: { openStyle.currentIndex = 1; openDuration.value = 150; openEasing.currentIndex = 0; switchStyle.currentIndex = 1; switchDuration.value = 120; cascade.checked = false; smoothHover.checked = true; hoverDuration.value = 100 }
            }
            QQC2.Button {
                text: i18n("Lively")
                onClicked: { openStyle.currentIndex = 2; openDuration.value = 260; openEasing.currentIndex = 2; switchStyle.currentIndex = 2; switchDuration.value = 200; cascade.checked = true; cascadeDelay.value = 15; smoothHover.checked = true; hoverDuration.value = 120 }
            }
        }
    }
}
