import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-system-windows"
        source: "ConfigGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-color"
        source: "ConfigAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Animations")
        icon: "preferences-desktop-effects"
        source: "ConfigAnimations.qml"
    }
    ConfigCategory {
        name: i18n("Position & Size")
        icon: "transform-move"
        source: "ConfigPosition.qml"
    }
}
