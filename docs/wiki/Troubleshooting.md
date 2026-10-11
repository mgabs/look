# Troubleshooting & Diagnostics

## 1. Hotkey (`Cmd+Space`) Does Not Open Look

* **Spotlight Conflict**: Ensure the default macOS Spotlight shortcut has been disabled or reassigned.
  - Open **System Settings** -> **Keyboard** -> **Keyboard Shortcuts...** -> **Spotlight** -> Uncheck **Show Spotlight search**.
* **Accessibility Permissions**: If Look does not have Accessibility permission, macOS will drop global keystrokes.
  - Open **System Settings** -> **Privacy & Security** -> **Accessibility** -> Toggle **Look** Off and On.
* **Process Stuck**: Quit any hung instance:
  ```bash
  killall Look || true
  ```

---

## 2. Results Seem Stale, Missing, or Empty

* **Force Reload Configuration**:
  - Press `Cmd+Shift+;` while Look is open to trigger an immediate config re-read and cache invalidation.
* **Inspect Scan Limits & Roots**:
  - Open `~/.look.config` and verify `file_scan_roots` includes the expected directories (e.g. `~/Documents`, `~/Desktop`).
  - Verify that `file_scan_limit` has not been exceeded.
* **Inspect Exclude Rules**:
  - Ensure parent directory basenames are not matched by `skip_dir_names` or `file_exclude_paths`.

---

## 3. Database Diagnostics & Repair

Look stores its candidates, search frecency, and tasks in a local SQLite database at:
```bash
~/Library/Application Support/look/look.db
```

### Inspecting Indexed Items
```bash
sqlite3 "$HOME/Library/Application Support/look/look.db" \
  "SELECT id, title, use_count FROM candidates ORDER BY use_count DESC LIMIT 20;"
```

### Resetting the Search Index
If the local database becomes corrupted or out of sync:
```bash
killall Look
rm "$HOME/Library/Application Support/look/look.db"
# Relaunch Look - it will recreate the database automatically on startup
```

---

## 4. Enabling Verbose Debug Logs

Run Look from Terminal with debug flags:

```bash
LOOK_LOG_LEVEL=debug /Applications/Look.app/Contents/MacOS/Look
```

Or stream live logs via macOS `log` stream:

```bash
log stream --predicate 'subsystem == "noah-code.Look"' --level debug
```
