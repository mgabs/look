# Configuration Reference

Look is configured via a plain-text configuration file located at:

* **Default Path**: `~/.look.config` (or `~/.look/config`)
* **Environment Override**: `LOOK_CONFIG_PATH=/path/to/custom.config`
* **Live Reload Shortcut**: `Cmd+Shift+;` (reloads settings instantly without restarting the application)

---

## Configuration Syntax

* One `key = value` assignment per line.
* Lines beginning with `#` are comments.
* Missing keys automatically fall back to hardcoded defaults.

---

## File & Application Indexing

| Key | Default | Description |
| :--- | :--- | :--- |
| `app_scan_roots` | `/Applications, ~/Applications, /System/Applications` | Comma-separated paths scanned for application bundles |
| `app_scan_depth` | `3` | Maximum folder recursion depth when finding apps |
| `app_exclude_paths` | `""` | Paths excluded from app discovery |
| `app_exclude_names` | `""` | App bundle names hidden from search results |
| `file_scan_roots` | `~/Desktop, ~/Documents, ~/Downloads` | Search roots for document and file indexing |
| `file_scan_depth` | `4` | Maximum recursion depth for file search |
| `file_scan_limit` | `25000` | Maximum number of files indexed in SQLite |
| `file_exclude_paths`| `""` | Directories completely skipped by the scanner |
| `skip_dir_names` | `node_modules, .git, target, .build, Pods` | Directory basenames ignored during indexing |

---

## Calendar & Date Options

| Key | Default | Description |
| :--- | :--- | :--- |
| `secondary_calendar_type` | `none` | Optional secondary calendar: `none`, `hijri`, or `lunar` |
| `secondary_calendar_offset` | `0` | Integer day offset (e.g. `-1`, `0`, `1`) to adjust Hijri moon sighting |

When enabled, the launcher displays the secondary date (e.g. Islamic Hijri month name and day number, or Lunar phase) alongside the standard Gregorian date in the launcher header.

---

## User Interface & Appearance

| Key | Default | Description |
| :--- | :--- | :--- |
| `ui_tint_red` | `0.1` | Window background tint red channel (0.0 to 1.0) |
| `ui_tint_green` | `0.1` | Window background tint green channel (0.0 to 1.0) |
| `ui_tint_blue` | `0.1` | Window background tint blue channel (0.0 to 1.0) |
| `ui_tint_opacity` | `0.85` | Background translucency opacity |
| `ui_blur_material` | `hudWindow` | macOS blur material style (`hudWindow`, `menu`, `popover`) |
| `ui_font_name` | `system` | Custom font family name for UI typography |
| `ui_font_size` | `15` | Base font size for candidate rows |
| `ui_border_thickness` | `1.0` | Outer window border stroke width in pixels |
| `running_apps_placement` | `right` | Running apps bar: `right`, `none` |

---

## System & Diagnostics

| Key | Default | Description |
| :--- | :--- | :--- |
| `backend_log_level` | `info` | Logging verbosity: `trace`, `debug`, `info`, `warn`, `error` |
| `launch_at_login` | `false` | Automatically launch Look on macOS user login |
| `ai_enabled` | `true` | Toggle web answer cards and suggestions globally |
| `translate_allow_network` | `true` | Allow external network calls for language translation |
