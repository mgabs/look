# Look Wiki

Welcome to the **Look** documentation wiki.

**Look** is a keyboard-first, ultra-low-latency desktop launcher designed for power users on macOS (with cross-platform support for Linux and Windows via Linows). It marries a high-performance Rust core engine with a fluid, native SwiftUI/AppKit desktop interface.

---

## Wiki Navigation

### 📖 User Guide
* **[Getting Started](Getting-Started.md)**: Requirements, installation via Homebrew Tap, initial setup, permissions, and first launch.
* **[User Workflow & Shortcuts](User-Workflow-and-Shortcuts.md)**: Keyboard cheat sheet, search modes, query prefixes (`a"`, `f"`, `d"`, `r"`, `c"`), path navigation, and Tab completion.
* **[Commands & System Actions](Commands-and-Actions.md)**: Inline system commands (`:sleep`, `:lock`, `:mute`, `:theme`, `:caff`), Command mode (`Cmd+/`), Pomodoro, Todos, Speed test, Process killer, Math/Unit/Timestamp conversions.
* **[Super Actions & Launchpad](Super-Actions-and-Launchpad.md)**: Empty-state grid layout (`~/.look/super-actions.toml`), interactive status tiles, L-slot, and Running Apps switcher bar.
* **[AI & Intelligence](AI-and-Intelligence.md)**: Instant answer cards (DDG, Wikipedia, Apple Intelligence, Ollama), conversational assistant (`>`), natural language meeting joins, contacts actions, and offline privacy model.
* **[Configuration Reference](Configuration-Reference.md)**: Complete guide to `~/.look.config` including indexing paths, exclude lists, Hijri/Lunar secondary calendar options, theme keys, and hotkeys.
* **[Custom Sources & Extensibility](Sources-and-Extensibility.md)**: Creating custom CLI sources in `~/.look/sources/`, executable contract, and JSON protocol.

### 🛠 Contributor & Technical Documentation
* **[Architecture Overview](Architecture-Overview.md)**: Core Rust crates, C FFI bridge, native SwiftUI layer, Tauri Linows shell, and SQLite database storage.
* **[Developer & Contributor Guide](Developer-and-Contributor-Guide.md)**: Dev environment setup, build commands, test suites, and release packaging.
* **[Troubleshooting & Diagnostics](Troubleshooting.md)**: Diagnosing shortcut conflicts, permissions issues, stale index data, and SQLite inspection.
* **[Roadmap & Scope](Roadmap-and-Scope.md)**: Product pillars, near-term priorities, long-term visions, and explicit non-goals.

---

## Core Principles

1. **Sub-millisecond Feedback**: Typing generates instant local candidate results without network delays or GC pauses.
2. **Keyboard-First**: Every action, preview, clipboard item, and system toggle has dedicated single-key or chorded navigation.
3. **Local-First & Private**: Search indexes, clipboard history, tasks, and notes remain on your device in SQLite. No tracking or telemetry.
4. **Focused Utility**: High-utility built-in tools (pomodoro, daily tasks, speed test, math/unit conversions) instead of heavy web plugins.
