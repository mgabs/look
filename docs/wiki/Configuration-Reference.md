# Configuration Reference

Config file: **`~/.look/config`** (legacy `~/.look.config` is still read). Override the path with `LOOK_CONFIG_PATH`.

- One `key=value` per line; `#` starts a comment.
- Out-of-range or unparseable values fall back to defaults.
- Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux/Windows), or restart Look.

Full reference: [`docs/user-guide.md`](https://github.com/mgabs/look/blob/main/docs/user-guide.md).

## Indexing

- `app_scan_roots`, `app_scan_depth`, `app_exclude_paths`, `app_exclude_names`
- `file_scan_roots`, `file_scan_extra_roots`, `file_scan_depth`, `file_scan_limit`, `file_exclude_paths`
- `ignored_patterns_<group>`: gitignore-style globs (`*`, `**`, `?`, `[abc]`), values separated by `|`, files only
- `lazy_indexing_enabled`
- `skip_dir_names`
- `alias_<keyword>`: app / System Settings aliases, e.g. `alias_note=Notion|Obsidian|Notes`

## Calendar (macOS clock tile)

- `secondary_calendar`: `none`, `lunar` (East Asian) or `hijri` (Islamic)
- `hijri_day_offset`: integer day offset to match local moon sighting (default `0`)

## Behaviour (file-only settings)

- `launcher_hotkey`: global show/hide shortcut. Default `cmd+space` (macOS), `alt+space` (Windows/Linux). Examples: `ctrl+space`, `alt+shift+space`, `f13`. `none` disables registration (bind `lookapp --toggle` yourself).
- `shortcut_<group>_<action>` (macOS): rebind in-app shortcuts, e.g. `shortcut_main_copy`. Multiple chords separated by `|`.
- `app_hotkey_<name>=<shortcut>|<target>`: global shortcut launching an app, e.g. `app_hotkey_terminal=cmd+shift+t|Ghostty`.
- `clipboard_history_limit`: 10 to 100, default `10`.
- `query_retention_seconds`: how long the query survives while hidden. Default `5`; `0` clears on every hide; negative keeps it.
- `translate_languages`: codes for the `t"` panel, default `vi,en,ja`.
- `text_editor`, `code_editor`, `terminal`, `file_manager`: preferred tools.

## System

- `backend_log_level`, `launch_at_login`, `add_to_path` (Windows)
- `ai_enabled`: toggles web answer cards and suggestions (on by default)
- `running_apps_placement`: `none` = off, any other value = on
