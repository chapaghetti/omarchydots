<img width="1920" height="37" alt="image" src="https://github.com/user-attachments/assets/554bae95-45c6-4495-9a01-198ab1b4c066" />
<img width="1919" height="37" alt="image" src="https://github.com/user-attachments/assets/1ecc8fb9-f0ef-44ed-998c-b92be1829d3f" />
<img width="1920" height="37" alt="image" src="https://github.com/user-attachments/assets/2b09ce20-b1a4-489e-bde1-49e83eb61504" />
<img width="1920" height="37" alt="image" src="https://github.com/user-attachments/assets/5ed0d230-fb11-4258-9df3-c9a4e708fc12" />

----------------------------------------------------------------------------

(For use with Omarchy 4.0 setups with QuickShell & Hyprland w/ Lua) 

Modifies the default Omarchy Quattro dots (Hypr/Omarchy)
- Removes the solid colored QuickShell bar
- Replaces it with pillbox styled plugin capsules
- Uses Chinese characters for workspaces 1-10
- Adds a dynamically sized expandable system tray whose pillbox capsule grows and shrinks with the drawer.
- Accents the Omarchy button and the active workspace icon with the current theme's accent color
- Sets battery to yellow when less than 50% and red when less than 15%
- Sets active omarchy.indicators to a red color
- Adds disk, memory, and cpu usage plugins that open btop when pressed

Themes shown:
- Tokyo Night
- Miasma (https://github.com/OldJobobo)
- Last Horizon
- Catppuccin
  
----------------------------------------------------------------------------

Omarchy Custom Bar — Pillbox & Expandable Tray

An overview of the customizations applied to the Omarchy shell/bar for a pillboxed,
floating-module look with an expandable system tray whose capsule grows and
shrinks with the drawer.

---

Pillbox — floating capsule around every plugin

**Why the standard bar couldn't do this:** the default `omarchy.bar` paints one
full-width background rectangle for the whole bar. The pillbox look instead
requires the bar window to be *fully transparent* and each module to draw its
own rounded capsule.

Changes made (`~/.config/omarchy/plugins/nugget.bar/`)

**shell.json** — activate the custom bar and make it transparent:

```json
"bar": { "id": "nugget.bar", "position": "top", "transparent": true, ... }
```

**`Bar.qml` → `ModuleSlot` (~line 1524)** — the slot that hosts each plugin is
turned into a padded capsule:

```qml
implicitWidth:  activeItem.implicitWidth + pillPadX * 2   // slot hugs module content
implicitHeight: activeItem.implicitHeight + pillPadY * 2
readonly property int pillGap:  Style.space(5)
readonly property int pillPadX: root.vertical ? 0 : Style.space(3)
readonly property int pillPadY: root.vertical ? Style.space(3) : 0
readonly property color pillColor:  Color.popups.background
readonly property int pillRadius: Math.min(Style.space(8), Math.min(implicitWidth, implicitHeight) / 2)
```

and a `BorderSurface modulePill` (~line 1586) fills the slot with a 1px
top/bottom inset, `radius: slot.pillRadius`, hover-lightens the fill,
`opacity: 0.8`:

```qml
BorderSurface {
  visible: slot.activeItem && slot.activeItem.visible
  anchors.fill: parent
  anchors.topMargin: Style.space(1)
  anchors.bottomMargin: Style.space(1)
  color: moduleHover.hovered ? Qt.lighter(slot.pillColor, 1.1) : slot.pillColor
  radius: slot.pillRadius
  opacity: slot.dragSource ? 0.45 : 0.8

  Behavior on color {
    ColorAnimation { duration: 120 }
  }
}
```

The three module loaders (command / registry / qml) are inset by `pillPadX/Y`
so module content sits inside the pill. Section lists space pills apart with
`spacing: Style.space(5)` (= `pillGap`).

Key design insight

The slot sizes itself from `activeItem.implicitWidth`. The pillbox therefore
auto-hugs every module — which is *why* the tray fix below was required. Any
widget that reports a misleading implicit width (one that reserves hidden
extent) makes its pill permanently too big.

---

The expandable tray — pill shrinks/grows with the drawer

**Why the stock tray broke the pillbox:** `omarchy.tray`'s root
`implicitWidth = pinnedWidth + chevron + drawerExtent` — the *full*
collapsed+expanded drawer width was always reserved, so its pill was always
"expanded" sized even when closed.

Changes made (`~/.config/omarchy/plugins/nugget.tray/Tray.qml`, clone of the built-in)

- Resize by *revealed* extent instead of full extent (horizontal; vertical
  mirrored):

  ```qml
  readonly property real revealExtent: drawerExtent * revealProgress   // 0→1, 600ms ease
  readonly property int drawerBlockWidth: root.allItems.length > 0
      ? expandIcon.implicitWidth + root.revealExtent : 0
  ```

- Chevron stays anchored on screen: `expandIcon.x: root.revealExtent`

- Drawer icons slide in under a clip:
  `trayClip { x: 0; width: root.revealExtent; clip: true }`
  and `trayIcons.x: root.revealExtent - root.drawerExtent`

- Removed the `containmentMask` blocks that left dead hover space.

**Result:** collapsed pill = chevron only (**36px**), hovered pill grows
leftward to reveal the drawer (**72px**), collapses back on leave.
Verified via `omarchy-shell shell debugBarGeometry`:
`itemW` 36 ↔ 72, slot `w` 44 ↔ 80.

---

Supporting wiring

 `BarModel.js` (`nugget.bar`, line 29)

`pinTrayToInner` hard-matched the id `omarchy.tray`. Since the cloned tray is
`nugget.tray`, a helper was added so the tray still gets pinned to the inner
edge of the right section:

```js
function isTrayEntry(id) {
  if (id === "omarchy.tray" || id === "nugget.tray") return true
  return /\.tray$/.test(String(id || ""))
}
```

 shell.json

- Right-section entry `"id": "nugget.tray"` (replaces `omarchy.tray`).

- Custom command modules (`disk`, `mem`, `cpu`) in the left section calling
  `~/.config/omarchy/bar/scripts/*`:

  ```json
  {
    "id": "cpu",
    "type": "command",
    "exec": "~/.config/omarchy/bar/scripts/cpu-usage",
    "interval": 5,
    "tooltip": "CPU utilization",
    "onClick": "omarchy-launch-or-focus-tui btop"
  }
  ```

---

Recreation checklist

1. **Clone the bar:** `omarchy plugin clone omarchy.bar` → `nugget.bar`.
   Set `bar.id` to `nugget.bar` in shell.json, set `transparent: true`.
2. **Add the pillbox** to `ModuleSlot` in the cloned `Bar.qml` (implicit
   width/height padding + `BorderSurface modulePill` + inset the loaders +
   section `spacing: 5`).
3. **Add custom command modules:** drop scripts in
   `~/.config/omarchy/bar/scripts/`, reference them in shell.json layout
   (`"type": "command", "exec": ..., "interval": 5`).
4. **Clone the tray:** `omarchy plugin clone omarchy.tray` → `nugget.tray`;
   swap the shell.json right-section entry to `nugget.tray`.
5. **Apply the dynamic-sizing edits** to the cloned `Tray.qml` (drawerBlock
   from `revealExtent`, chevron/clip/icon positions, drop containmentMask;
   mirror for vertical).
6. **Fix `pinTrayToInner`** in the cloned `BarModel.js` with an
   `isTrayEntry` matcher.
7. **Reload** (`omarchy restart shell`) and verify with
   `omarchy-shell shell debugBarGeometry` — expect collapsed tray
   `itemW = 36`, hovered `itemW = 72`.

---

Files to touch / verify

| Purpose                          | File                                                 |
| -------------------------------- | ---------------------------------------------------- |
| Bar window transparency + bar id | `~/.config/omarchy/shell.json`                       |
| Pillbox capsule styling          | `~/.config/omarchy/plugins/nugget.bar/Bar.qml`       |
| Tray pinning helper              | `~/.config/omarchy/plugins/nugget.bar/BarModel.js`   |
| Expandable tray sizing           | `~/.config/omarchy/plugins/nugget.tray/Tray.qml`     |
| Custom command module scripts    | `~/.config/omarchy/bar/scripts/{cpu,disk,mem}-usage` |
| Geometry verification (IPC)      | `omarchy-shell shell debugBarGeometry`               |

Revert paths

- Restore the original tray: swap shell.json entry back to `omarchy.tray` and
  `omarchy plugin remove nugget.tray` (or restore the `shell.json.bak.pillbox.*`
  backup), and optionally undo the `isTrayEntry` change in `BarModel.js`.
