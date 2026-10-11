# Super Actions & Launchpad

When Look is opened with an empty query, it displays the **Launchpad**: a tactile, keyboard-driven dashboard containing interactive status tiles, quick hardware controls, and the **Running Apps** switcher strip.

---

## 1. Running Apps Switcher Strip

The Running Apps switcher sits on the right side of the search header:
* **Stable Layout**: Shows up to 9 active applications, sorted alphabetically with persistent key positions.
* **Ergonomic Number Badging**: Uses an outer-to-inner finger placement (`1, 2, 3, 9, 8` before `4, 7, 6, 5`).
* **Direct Switching**: Press `Cmd + <Digit>` (macOS) or `Alt + <Digit>` (Linux/Windows) to instantly bring that application to the front.
* **Configuration**: Toggle in Settings or via `running_apps_placement = right` (or `none`) in `~/.look.config`.

---

## 2. Super Actions Grid

The lower half of the empty-state window renders a grid of status and control tiles.

### Built-in Tile Set

| Tile Name | Role | Interactive Key (Cmd + Key) | Description |
| :--- | :--- | :--- | :--- |
| **L-Slot** | Multifunction Hub | — | Displays active Pomodoro -> daily Todo progress -> Clock |
| **Wi-Fi** | Network Toggle | `Cmd+W` | Toggle Wi-Fi state / display connected SSID |
| **Bluetooth** | Wireless Toggle | `Cmd+B` | Toggle Bluetooth controller |
| **Battery** | Hardware Status | — | Battery percentage, health status, and charging indicator |
| **Theme** | Appearance | `Cmd+T` | Toggle macOS Dark Mode / Light Mode |
| **Keep Awake** | System Power | `Cmd+K` | Toggle display/system sleep inhibitor |
| **Screensaver** | Display Lock | `Cmd+S` | Engage screen saver immediately |
| **Weather** | Environmental | — | Real-time temperature and weather conditions |
| **Mic** | Audio Privacy | `Cmd+M` | Mute / unmute microphone input globally |
| **Restart** | System Power | `Cmd+R` | Two-stage armed restart (requires double tap) |
| **Shut Down** | System Power | `Cmd+D` | Two-stage armed shutdown (requires double tap) |
| **Now Playing** | Media Control | `Cmd+P` | Play / Pause active system media playback |

---

## 3. Customizing the Grid Layout (`~/.look/super-actions.toml`)

Look layouts are completely user-customizable. Edit `~/.look/super-actions.toml`:

```toml
# Layout grid definition
# Repeating a name makes that tile span multiple columns/rows.
# Use '.' for an empty blank cell.

grid = """
lslot   lslot   wifi    bluetooth  battery   theme
lslot   lslot   weather weather    keepawake screensaver
restart shutdown mic     nowplaying nowplaying .
"""
```

### Safety & Fallback
If `~/.look/super-actions.toml` has syntax errors or an invalid tile specification, Look automatically falls back to its built-in default layout without crashing or failing to launch.
