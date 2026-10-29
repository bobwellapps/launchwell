/*
 * SPDX-FileCopyrightText: 2026 bobwellapps
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import org.kde.iconthemes as KIconThemes

// Kept in its own file and loaded on demand, so if the icon dialog
// module is ever missing only "Choose icon" stops working.
Item {
    id: picker

    property string targetKey: ""
    signal picked(string key, string icon)

    function openPicker() {
        dialog.open();
    }

    KIconThemes.IconDialog {
        id: dialog
        onIconNameChanged: {
            if (picker.targetKey.length > 0 && iconName) {
                picker.picked(picker.targetKey, iconName);
            }
        }
    }
}
