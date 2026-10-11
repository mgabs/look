# Commands & System Actions

Look provides two layers of command execution:
1. **Inline Quick Actions** (`:command` syntax) for instant system controls.
2. **Command Mode** (`Cmd+/` or `:cmdid`) for interactive built-in utility applications.

---

## 1. Inline Quick System Commands

Type a colon `:` followed by the command name to trigger instantaneous actions without opening menus:

* **`:sleep`**: Puts displays and the operating system into sleep mode immediately.
* **`:lock`**: Instantly locks the user session screen.
* **`:mute`**: Toggles system audio output between muted and unmuted states.
* **`:theme`**: Cycles system appearance dynamically between Dark and Light mode.
* **`:caff`**: Toggles macOS `caffeinate` background sleep prevention.

---

## 2. Command Mode (`Cmd+/`)

Press `Cmd+/` to enter the full-screen Command Mode catalog. You can also trigger a specific tool directly by typing its mnemonic (e.g. `:pomo`, `:calc 2+2`, `:kill 3000`).

### Built-in Applications

#### 🍅 Pomodoro Focus Timer (`:pomo`)
* **Focus Engine**: Configurable intervals (e.g. 25m focus, 5m break) with interactive audio alerts.
* **Timer Styles**: Switch between Modern Ring, Vintage Dial, and Minimalist Text dials.
* **Ambient Sound**: Point to any local folder of audio tracks for background focus music.
* **Menu Bar Indicator**: Mini-timer persists in the macOS status menu bar during sessions.

#### ✅ Daily Tasks (`:todo`)
* **Daily Kanban**: Structured daily agenda grouping (3 daily focal tasks, overdue badges, completed tasks).
* **Fuzzy Filtering**: Search your task history dynamically across descriptions and target dates.
* **Productivity Stats**: Completion streaks, monthly heatmaps, and weekly velocity charts.
* **Undo History**: 50-step in-memory undo/redo via `Cmd+Z` / `Cmd+Shift+Z`.

#### ⚡ Speed Test (`:speed`)
* **Live Visual Dial**: Real-time download/upload dials measuring from 1 Mbps up to 10 Gbps with latency jitter tracking.
* **Network Inspection**: Displays internal LAN IPv4, external WAN IP (click-to-copy or click-to-mask), and ISP identification.
* **Engine**: Benchmarked against Cloudflare CDN edge nodes without external binary dependencies (`core/netspeed`).

#### 🧮 Advanced Calculator & Converter (`:calc` or `=`)
Look includes an integrated parsing engine (`core/calc` & `QuickMathService`):
* **Math Expressions**: Factorials (`5!`), powers (`2^8`), trigonometric functions, logarithms, brackets (`(4 + 8) * 2`).
* **Unit Conversions**: Automatically converts between metric and imperial systems:
  - *Distance*: `100 km in mi`, `50 miles to km`
  - *Temperature*: `100 c in f`, `72 f to c`
  - *Weight*: `5 kg in lbs`, `150 lbs to kg`
* **Currency Conversion**: Live and cached fiat conversion (e.g. `100 usd in eur`, `50 gbp to jpy`).
* **Timestamp Inspector**: Convert Unix timestamps directly to human readable dates:
  - Input: `1700000000` -> Output: `Wed, 15 Nov 2023 22:13:20 UTC`
  - Input: `now timestamp` -> Output: Current epoch timestamp.

#### 🛑 Process & Port Killer (`:kill` / `ps"`)
* **Kill by Name**: Fuzzy search across running processes and terminate with confirmation.
* **Kill by Port**: Target stuck local web servers (e.g. `:kill 3000` or `ps"8080`) to immediately release locked network sockets.

#### 🐚 Shell Executor (`:shell`)
* Execute ad-hoc terminal snippets directly from the launcher.
* **Safety Cue**: Displays an orange visual warning when input contains `sudo` or privileged commands.
