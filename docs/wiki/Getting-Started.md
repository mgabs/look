# Getting Started

## System Requirements

* **macOS**: 15.0+ (macOS Sequoia recommended for full Apple Intelligence & Spotlight integration).
* **Linux**: System with GTK3/WebKit2GTK, GNOME / KDE Wayland or X11 (via `apps/linows`).
* **Windows**: Windows 10/11 x64 (via `apps/linows`).

---

## Installation

### macOS (Recommended: Homebrew Tap)

Install via the maintained Homebrew tap:

```bash
brew install --cask mgabs/tap/look
```

Or tap first, then install:

```bash
brew tap mgabs/tap
brew install --cask look
```

### Direct Download & Installation Script

Run the automated installer:

```bash
curl -fsSL https://raw.githubusercontent.com/mgabs/look/main/scripts/install-look.sh | bash
```

To pin a specific version or install a custom asset:

```bash
curl -fsSL https://raw.githubusercontent.com/mgabs/look/main/scripts/install-look.sh | bash -s -- --version 0.8.0
```

### Linux

Using the automated install script:

```bash
curl -fsSL https://raw.githubusercontent.com/mgabs/look/main/scripts/linux/install-look.sh | bash
```

Or install the `.deb` release package manually:

```bash
sudo dpkg -i Look_*.deb
```

### Windows

Install via PowerShell:

```powershell
iex "& { $(irm https://raw.githubusercontent.com/mgabs/look/main/scripts/windows/install-look.ps1) }"
```

---

## First-Run Setup & Permissions (macOS)

### 1. Unbind Default Spotlight Hotkey
Look uses `Cmd+Space` by default. To prevent macOS Spotlight from intercepting the hotkey:
1. Open **System Settings** -> **Keyboard** -> **Keyboard Shortcuts...**.
2. Select **Spotlight** in the left sidebar.
3. Uncheck **Show Spotlight search** (or assign it to another key chord like `Ctrl+Space`).

### 2. Privacy & Security Permissions
Look requires specific macOS permissions for system-level controls:
* **Accessibility**: Required to read active window titles and simulate keystrokes for clipboard pasting (`Cmd+I`).
  - *Location*: System Settings -> Privacy & Security -> Accessibility -> Enable **Look**.
* **Automation (System Events)**: Required for system sleep, mute, and appearance toggles.
* **Calendars & Contacts** *(Optional)*: Required for calendar event previews, meeting join shortcuts, and contact communications.

### 3. Gatekeeper Bypass
If building locally or installing an ad-hoc signed development build:
* Right-click `Look.app` in `/Applications` -> Select **Open** -> Click **Open** in the confirmation dialog.
* Or allow via System Settings -> Privacy & Security -> **Open Anyway**.

---

## Verifying Installation

Launch Look by pressing `Cmd+Space`. You will see the Look launcher interface appear instantaneously in the center of the display.
To verify CLI symlinks:

```bash
lookapp --version
```
