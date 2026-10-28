import QtQuick
import org.kde.kirigami as Kirigami
import "tools.js" as Tools

// Draws an icon in colour or mono.
//  - classic: use the bundled Plasma 5 colour icon when there is one
//             (falls back to the icon theme if that file can't be loaded)
//  - mono:    ask the theme for the "-symbolic" version and tint it
//  - colour:  ask the theme for the plain (non "-symbolic") name; Breeze
//             draws some of those mono at 16/22px, so render at 48px and
//             scale down when forceColour is on.
Item {
    id: box

    property var source
    property int size: Kirigami.Units.iconSizes.medium
    property bool mono: false
    property bool classic: false
    property bool forceColour: true
    property bool active: false

    implicitWidth: size
    implicitHeight: size

    readonly property bool isName: Tools.isIconName(source)
    readonly property string classicFile: (classic && !mono) ? Tools.classicIcon(source) : ""
    readonly property bool showClassic: classicFile.length > 0 && classicImage.status !== Image.Error

    readonly property var themed: {
        if (typeof source === "string" && source.startsWith("/")) {
            return "file://" + source;          // absolute path from a .desktop file
        }
        if (!isName) {
            return source;                      // a QIcon or URL: use as given
        }
        const base = source.replace(/-symbolic$/, "");
        return mono ? base + "-symbolic" : base;
    }

    readonly property int renderSize: (!mono && forceColour && size < 48) ? 48 : size

    // Bundled classic icon (plain SVG file in contents/icons)
    Image {
        id: classicImage
        anchors.fill: parent
        visible: box.showClassic
        source: box.classicFile.length > 0 ? Qt.resolvedUrl("../icons/" + box.classicFile + ".svg") : ""
        sourceSize: Qt.size(box.size * 2, box.size * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        asynchronous: false
        onStatusChanged: {
            if (status === Image.Error) {
                console.warn("Launchwell: could not load bundled icon", source);
            }
        }
    }

    // Icon from the icon theme
    Kirigami.Icon {
        anchors.centerIn: parent
        visible: !box.showClassic
        width: box.renderSize
        height: box.renderSize
        scale: box.size / box.renderSize
        source: box.themed
        // Plain name first (for mono), then a generic app icon like Kickoff shows
        fallback: box.isName && box.mono ? box.source.replace(/-symbolic$/, "") : "application-x-executable"
        isMask: box.mono
        color: Kirigami.Theme.textColor
        active: box.active
        animated: false
        smooth: true
        layer.enabled: visible && box.renderSize !== box.size
        layer.smooth: true
        layer.mipmap: true
    }
}
