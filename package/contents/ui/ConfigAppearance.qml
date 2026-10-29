/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQControls
import QtQuick.Dialogs as Dialogs

KCM.SimpleKCM {
    id: page

    property alias cfg_categoryIconStyle: catStyle.currentIndex
    property alias cfg_appIconStyle: appStyle.currentIndex
    property alias cfg_forceColour: forceColour.checked
    property alias cfg_categoryIconSize: catSize.value
    property alias cfg_appIconSize: appSize.value
    property alias cfg_gridIconSize: gridSize.value
    property alias cfg_sidebarWidth: sidebarWidth.value
    property alias cfg_rowSpacing: rowSpacing.value
    property alias cfg_textScale: textScale.value
    property alias cfg_backgroundStyle: bgStyle.currentIndex
    property string cfg_customBgColor: "#232629"
    property alias cfg_customBgOpacity: bgOpacity.value
    property alias cfg_cornerRadius: cornerSpin.value
    property string cfg_customBgImage: ""
    property alias cfg_bgImageFill: bgFill.currentIndex
    property alias cfg_bgImageBlur: bgBlur.value
    property alias cfg_bgImageDim: bgDim.value
    property var cfg_categoryIcons: []

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
    property var cfg_categoryIconsDefault
    property var cfg_favouritesSeeded
    property var cfg_favouritesSeededDefault
    property var cfg_categoryIconStyleDefault
    property var cfg_appIconStyleDefault
    property var cfg_forceColourDefault
    property var cfg_categoryIconSizeDefault
    property var cfg_appIconSizeDefault
    property var cfg_gridIconSizeDefault
    property var cfg_sidebarWidthDefault
    property var cfg_rowSpacingDefault
    property var cfg_textScaleDefault
    property var cfg_backgroundStyleDefault
    property var cfg_customBgColorDefault
    property var cfg_customBgOpacityDefault
    property var cfg_cornerRadiusDefault
    property var cfg_customBgImageDefault
    property var cfg_bgImageFillDefault
    property var cfg_bgImageBlurDefault
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






















    Kirigami.FormLayout {
        // ------------------------------------------------ icons
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Icons") }

        QQC2.ComboBox {
            id: catStyle
            Kirigami.FormData.label: i18n("Category icons:")
            model: [i18n("Classic colour (Plasma 5 / Kubuntu 24.04)"), i18n("Mono"), i18n("Colour from your icon theme")]
        }
        QQC2.ComboBox {
            id: appStyle
            Kirigami.FormData.label: i18n("App & button icons:")
            model: [i18n("Colour"), i18n("Mono")]
        }
        QQC2.CheckBox {
            id: forceColour
            text: i18n("Force full-colour artwork at small sizes")
        }
        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            text: i18n("Classic colour uses the Plasma 5 Breeze category icons bundled with Launchwell. For other icons, Breeze uses mono drawings at 16–22 px; with this option on they are drawn from the 48 px artwork and scaled down. Right-click any category in the menu to give it a different icon.")
        }
        QQC2.Button {
            text: i18n("Reset all custom category icons")
            icon.name: "edit-undo"
            enabled: page.cfg_categoryIcons && page.cfg_categoryIcons.length > 0
            onClicked: page.cfg_categoryIcons = []
        }

        QQC2.SpinBox { id: catSize; Kirigami.FormData.label: i18n("Category icon size:"); from: 16; to: 64 }
        QQC2.SpinBox { id: appSize; Kirigami.FormData.label: i18n("List icon size:"); from: 16; to: 96 }
        QQC2.SpinBox { id: gridSize; Kirigami.FormData.label: i18n("Grid icon size:"); from: 24; to: 128 }

        // ------------------------------------------------ spacing & text
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Spacing & text") }

        QQC2.SpinBox { id: sidebarWidth; Kirigami.FormData.label: i18n("Category list width:"); from: 120; to: 500; stepSize: 10 }
        QQC2.SpinBox { id: rowSpacing; Kirigami.FormData.label: i18n("Extra row padding:"); from: 0; to: 20 }
        RowLayout {
            Kirigami.FormData.label: i18n("Text size:")
            QQC2.Slider { id: textScale; from: 70; to: 160; stepSize: 5; Layout.preferredWidth: Kirigami.Units.gridUnit * 10 }
            QQC2.Label { text: textScale.value + "%" }
        }

        // ------------------------------------------------ background
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Background") }

        QQC2.ComboBox {
            id: bgStyle
            Kirigami.FormData.label: i18n("Style:")
            model: [i18n("Plasma theme (translucent)"), i18n("Plasma theme (solid)"), i18n("Custom colour"), i18n("Picture")]
        }
        KQControls.ColorButton {
            Kirigami.FormData.label: i18n("Colour:")
            enabled: bgStyle.currentIndex === 2
            color: page.cfg_customBgColor
            onColorChanged: page.cfg_customBgColor = color.toString()
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Opacity:")
            enabled: bgStyle.currentIndex >= 2
            QQC2.Slider { id: bgOpacity; from: 20; to: 100; stepSize: 1; Layout.preferredWidth: Kirigami.Units.gridUnit * 10 }
            QQC2.Label { text: bgOpacity.value + "%" }
        }
        QQC2.SpinBox {
            id: cornerSpin
            Kirigami.FormData.label: i18n("Corner radius:")
            enabled: bgStyle.currentIndex >= 2
            from: 0; to: 40
        }

        // ------------------------------------------------ picture
        RowLayout {
            Kirigami.FormData.label: i18n("Picture:")
            enabled: bgStyle.currentIndex === 3
            Image {
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                source: page.cfg_customBgImage
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: Kirigami.Units.gridUnit * 10
                visible: page.cfg_customBgImage.length > 0
            }
            QQC2.Label {
                visible: page.cfg_customBgImage.length === 0
                text: i18n("None chosen")
                opacity: 0.7
            }
            QQC2.Button {
                icon.name: "document-open"
                text: i18n("Choose…")
                onClicked: pictureDialog.open()
            }
            QQC2.Button {
                icon.name: "edit-clear"
                visible: page.cfg_customBgImage.length > 0
                QQC2.ToolTip.text: i18n("Remove picture")
                QQC2.ToolTip.visible: hovered
                onClicked: page.cfg_customBgImage = ""
            }
        }
        QQC2.ComboBox {
            id: bgFill
            Kirigami.FormData.label: i18n("Picture fits by:")
            enabled: bgStyle.currentIndex === 3
            model: [i18n("Filling the menu (cropped)"), i18n("Fitting inside (whole picture)"),
                    i18n("Stretching"), i18n("Tiling"), i18n("Centred, actual size")]
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Blur:")
            enabled: bgStyle.currentIndex === 3
            QQC2.Slider { id: bgBlur; from: 0; to: 64; stepSize: 1; Layout.preferredWidth: Kirigami.Units.gridUnit * 10 }
            QQC2.Label { text: bgBlur.value === 0 ? i18n("Off") : Math.round(bgBlur.value / 64 * 100) + "%" }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Darken:")
            enabled: bgStyle.currentIndex === 3
            QQC2.Slider { id: bgDim; from: 0; to: 90; stepSize: 1; Layout.preferredWidth: Kirigami.Units.gridUnit * 10 }
            QQC2.Label { text: bgDim.value + "%" }
        }
        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            text: i18n("Darken lays a shade of your theme's background colour over the picture so text stays easy to read. Opacity and corner radius above apply to the picture too.")
        }

        Dialogs.FileDialog {
            id: pictureDialog
            title: i18n("Choose a background picture")
            nameFilters: [i18n("Images (*.png *.jpg *.jpeg *.webp *.svg *.bmp *.gif)"), i18n("All files (*)")]
            onAccepted: page.cfg_customBgImage = selectedFile.toString()
        }
    }
}
