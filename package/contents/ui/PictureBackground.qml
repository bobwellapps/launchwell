/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Effects
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

// Menu background made from a picture of the user's choice:
// fill mode, blur, darkening layer, opacity and rounded corners.
// Loaded only when "Picture" is the background style.
Item {
    id: bg

    readonly property var cfg: Plasmoid.configuration
    readonly property int radius: cfg.cornerRadius
    readonly property real blurAmount: Math.max(0, Math.min(64, cfg.bgImageBlur)) / 64

    opacity: cfg.customBgOpacity / 100

    // Picture, blurred and clipped to the rounded shape in one effect
    Item {
        id: picture
        anchors.fill: parent
        visible: false            // drawn through the effect below
        layer.enabled: true       // the effect needs it rendered to a texture

        Image {
            id: image
            anchors.fill: parent
            source: bg.cfg.customBgImage
            asynchronous: true
            cache: true
            smooth: true
            mipmap: true
            fillMode: [Image.PreserveAspectCrop, Image.PreserveAspectFit, Image.Stretch,
                       Image.Tile, Image.Pad][Math.max(0, Math.min(4, bg.cfg.bgImageFill))]
            onStatusChanged: {
                if (status === Image.Error) {
                    console.warn("Launchwell: could not load background picture", source);
                }
            }
        }
    }

    Rectangle {
        id: shapeMask
        anchors.fill: parent
        radius: bg.radius
        visible: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: parent
        source: picture
        blurEnabled: bg.blurAmount > 0
        blur: bg.blurAmount
        blurMax: 64
        autoPaddingEnabled: false
        maskEnabled: true
        maskSource: shapeMask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }

    // Darkening layer so text stays readable on busy pictures
    Rectangle {
        anchors.fill: parent
        radius: bg.radius
        color: Kirigami.Theme.backgroundColor
        opacity: Math.max(0, Math.min(90, bg.cfg.bgImageDim)) / 100
    }

    // Thin edge like the colour background has
    Rectangle {
        anchors.fill: parent
        radius: bg.radius
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)
    }

    // Shown until a picture is chosen (or if it can't be loaded)
    Rectangle {
        anchors.fill: parent
        radius: bg.radius
        visible: image.status !== Image.Ready
        color: Kirigami.Theme.backgroundColor
    }
}
