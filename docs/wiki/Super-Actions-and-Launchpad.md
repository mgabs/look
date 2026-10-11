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

## 3. Enabling and Customizing

- **Off by default.** Enable in `Settings > Appearance > Super Actions` (`super_actions_enabled` in `~/.look/config`).
- Layout lives in `~/.look/super-actions.toml`: a drawing of the grid where each line is a row and each name a cell. Repeat a name to span cells, use `.` for a gap, delete a name to hide a tile. Max 5 rows x 6 columns.
- Minimum sizes: L slot 2x2, weather 1x2, now playing 2x1; undersized tiles are dropped.
- Seeded with the default layout on first run; delete the file to reset.
- A bad tile is dropped and the rest renders; a structural error falls back to the default layout.
- Restart and Shut Down arm on first press and fire on the second.
- Modifier: `Cmd` (macOS) / `Alt` (Linux, Windows).
