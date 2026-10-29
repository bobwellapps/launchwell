import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_menuWidth: menuWidth.value
    property alias cfg_menuHeight: menuHeight.value
    property alias cfg_dragResize: dragResize.checked
    property alias cfg_horizontalPosition: hPos.currentIndex
    property alias cfg_horizontalOffset: hOffset.value
    property alias cfg_verticalPosition: vPos.currentIndex
    property alias cfg_verticalGap: vGap.value
    property alias cfg_verticalOffset: vOffset.value
    property alias cfg_keepOnScreen: keepOnScreen.checked
    property alias cfg_windowType: winType.currentIndex

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
    property var cfg_menuWidthDefault
    property var cfg_menuHeightDefault
    property var cfg_dragResizeDefault
    property var cfg_horizontalPositionDefault
    property var cfg_horizontalOffsetDefault
    property var cfg_verticalPositionDefault
    property var cfg_verticalGapDefault
    property var cfg_verticalOffsetDefault
    property var cfg_keepOnScreenDefault
    property var cfg_windowTypeDefault
    // --- end






















    Kirigami.FormLayout {
        // ------------------------------------------------ size
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Size") }

        RowLayout {
            Kirigami.FormData.label: i18n("Width:")
            QQC2.SpinBox { id: menuWidth; from: 360; to: 3000; stepSize: 10; editable: true }
            QQC2.Label { text: i18n("px") }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Height:")
            QQC2.SpinBox { id: menuHeight; from: 300; to: 2000; stepSize: 10; editable: true }
            QQC2.Label { text: i18n("px") }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Presets:")
            QQC2.Button { text: i18n("Compact"); onClicked: { menuWidth.value = 560; menuHeight.value = 480 } }
            QQC2.Button { text: i18n("Classic"); onClicked: { menuWidth.value = 650; menuHeight.value = 560 } }
            QQC2.Button { text: i18n("Large");   onClicked: { menuWidth.value = 820; menuHeight.value = 720 } }
        }
        QQC2.CheckBox {
            id: dragResize
            text: i18n("Resize by dragging the menu's edges")
        }
        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            text: i18n("Drag the top, sides or corners of the open menu. The edge against the taskbar stays put. The new size is saved here automatically.")
        }

        // ------------------------------------------------ position
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Position") }

        QQC2.ComboBox {
            id: hPos
            Kirigami.FormData.label: i18n("Horizontal:")
            model: [i18n("Centre of screen"), i18n("Centred on the launcher button"), i18n("Left edge"), i18n("Right edge")]
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Nudge sideways:")
            QQC2.SpinBox { id: hOffset; from: -3000; to: 3000; editable: true }
            QQC2.Label { text: i18n("px (positive = right)") }
        }

        QQC2.ComboBox {
            id: vPos
            Kirigami.FormData.label: i18n("Vertical:")
            model: [i18n("Just above the panel"), i18n("Centre of screen"), i18n("Top of screen")]
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Gap from panel/edge:")
            QQC2.SpinBox { id: vGap; from: 0; to: 400; editable: true }
            QQC2.Label { text: i18n("px") }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Nudge up/down:")
            QQC2.SpinBox { id: vOffset; from: -3000; to: 3000; editable: true }
            QQC2.Label { text: i18n("px (positive = up)") }
        }
        QQC2.CheckBox {
            id: keepOnScreen
            text: i18n("Never let the menu go off screen")
        }
        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            text: i18n("\"Above the panel\" follows the panel: below it for a top panel, beside it for a side panel. Press Apply with the menu open to see changes straight away.")
        }

        // ------------------------------------------------ advanced
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Advanced") }

        QQC2.ComboBox {
            id: winType
            Kirigami.FormData.label: i18n("Window type:")
            model: [i18n("Applet popup (recommended)"), i18n("Normal"), i18n("Popup menu")]
        }
        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            text: i18n("Only change this if the menu ignores its position or doesn't take keyboard focus.")
        }
    }
}
