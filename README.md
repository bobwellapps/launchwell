
# Launchwell

**A Kickoff-style application launcher for KDE Plasma 6, with colour icons back and lots to tweak.**

Since Plasma 6.2, the stock launcher draws its category icons in mono. Launchwell
brings back the full-colour category icons from Plasma 5, keeps the familiar
layout (search on top, categories down the side, apps on the right, power
buttons along the bottom) and lets you rearrange and restyle almost all of it.

<img width="1920" height="1080" alt="currentscreen" src="https://github.com/user-attachments/assets/1a344cec-d89c-4b90-8214-42ce35d6e4ff" />

## Features

**Icons**
- Classic Plasma 5 colour category icons, bundled, so they work with any icon theme
- Mono icons as an option, separately for categories and for apps
- Choose your own icon for any category (right-click it)
- Panel button: classic colour logo, the new Plasma 6 logo, or any icon you like

**Layout**
- Search bar at the top, at the bottom, or in the footer beside the settings or power buttons
- Power/Session buttons and the Settings button can each go in the footer, top bar, or under the categories
- Category list on the left or right
- List or grid view, separately for favourites and for applications
- Clickable A–Z letter headings to jump through All Applications

**Size and position**
- Opens centred just above the taskbar by default
- Or at the launcher button, at the screen edge, screen centre or top, with pixel nudges
- Resize by dragging the menu's top, sides or corners, or type an exact size

**Look**
- Plasma theme background (translucent or solid), a custom colour, or your own picture
- Picture backgrounds with fill modes, blur and darkening
- Adjustable icon sizes, text size, row spacing, opacity and corner radius

**Animations**
- Opening effects: fade, slide from the taskbar, zoom or unfold, with speed and feel
- Category switching, apps cascading in, smooth hover highlights
- Follows Plasma's global animation speed

**Works properly with multiple monitors:** apps open on the monitor you launched them from.

## Requirements

- KDE Plasma 6.0 or newer (tested on Kubuntu 26.04)

## Install

### Easiest: from a downloaded file

1. Download the latest `launchwell-x.y.z.plasmoid` from the
   [Releases](../../releases) page.
2. Right-click your panel → **Add or Manage Widgets…** → **Get New** →
   **Install Widget From Local File…** and choose the file.
3. Put it on your panel: right-click your current launcher →
   **Show Alternatives…** → **Launchwell**. Or drag **Launchwell** from the
   widget list onto the panel.

### From the command line

```bash
kpackagetool6 -t Plasma/Applet -i launchwell-x.y.z.plasmoid
systemctl --user restart plasma-plasmashell
```

## Update

Download the new `.plasmoid` and run:

```bash
kpackagetool6 -t Plasma/Applet -u launchwell-x.y.z.plasmoid
systemctl --user restart plasma-plasmashell
```

(Plasma's "Install From Local File" won't install over an existing copy, so
either use the command above or remove the old version first.)

## Uninstall

```bash
kpackagetool6 -t Plasma/Applet -r org.launchwell.launcher
systemctl --user restart plasma-plasmashell
```

## Settings

Everything is under right-click → **Configure Launchwell…**, or the cog button
in the menu:

| Page | What's there |
|---|---|
| General | Panel button icon and label, layout, where the search bar and buttons go, behaviour, which power buttons to show |
| Appearance | Colour or mono icons, icon and text sizes, spacing, background style, colour or picture |
| Animations | Opening/closing effects, category switching, cascade, hover, presets |
| Position & Size | Width and height, drag-to-resize, where the menu opens, nudges |

## Troubleshooting

- **See what Launchwell is reporting:**
  `journalctl --user -b -t plasmashell | grep -i launchwell`
- **Changes not showing after an update:** restart Plasma with
  `systemctl --user restart plasma-plasmashell`.
- **Menu ignores its position or doesn't take keyboard focus:** Configure →
  Position & Size → Advanced → try the **Normal** window type.

## Building from source

```bash
git clone <this repository>
cd launchwell
./build.sh          # makes dist/launchwell-<version>.plasmoid
./install.sh        # or install/update straight from the source folder
```

The widget itself is plain QML in `package/`, with no compiling needed.

### Making a release

1. Bump `Version` in `package/metadata.json` **and** `version` in
   `package/contents/ui/tools.js` (`build.sh` checks they match).
2. Commit, then tag and push: `git tag v1.2.0 && git push --tags`
3. GitHub Actions builds the `.plasmoid` and attaches it to a new release.

## Licence

- Launchwell is released under the **GNU General Public License v2.0 or later**
  (see [LICENSE](LICENSE)).
- The bundled classic category icons in `package/contents/icons/` are from KDE's
  **Breeze icon theme** (© Uri Herrera and others), used under the
  **GNU LGPL v3 or later**. See the notice and licence texts in that folder.

Launchwell is an independent project and is not made by or affiliated with KDE.
