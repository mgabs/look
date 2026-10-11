# Architecture Overview

Look combines a native macOS user interface with an ultra-fast compiled Rust core.

---

## 1. High-Level Component Stack

```text
┌────────────────────────────────────────────────────────┐
│               macOS UI Shell (SwiftUI / AppKit)        │
│             apps/macos/LauncherApp/look-app            │
└───────────────────────────┬────────────────────────────┘
                            │ C FFI Bridge (C ABI)
                            ▼
┌────────────────────────────────────────────────────────┐
│                     bridge/ffi                         │
│   Memory buffer management, JSON serialization, C ABI  │
└───────────────────────────┬────────────────────────────┘
                            │ Native Rust calls
                            ▼
┌────────────────────────────────────────────────────────┐
│                   Core Rust Crates                     │
│  core/engine   - Query parsing, indexing orchestration │
│  core/calc     - Math, units, timestamps, currency     │
│  core/qactions - Super actions grid and status tiles   │
│  core/storage  - SQLite database persistence           │
│  core/ranking  - Frecency scoring & fuzzy matching     │
│  core/netspeed - Multi-stream speed test engine        │
│  core/todo     - Daily Kanban task database            │
└────────────────────────────────────────────────────────┘
```

---

## 2. Core Rust Crates Breakdown

* **`core/engine`**: Primary coordinator. Oversees query normalization, scanner threads, candidate caching, and search dispatch.
* **`core/calc`**: Parses mathematical queries, unit conversions, currency exchange, and Unix timestamp parsing without external scripting interpreters.
* **`core/qactions`**: Resolves layout grids for the Super Actions launchpad from `~/.look/super-actions.toml`.
* **`core/storage`**: Manages the SQLite database located at `~/Library/Application Support/look/look.db`. Handles candidates, usage frequency, and migration schemas.
* **`core/ranking`**: Frecency (frequency + recency) ranking model that dynamically promotes frequently selected results.
* **`bridge/ffi`**: Exports C-compatible functions (`look_search`, `look_execute_action`, `look_get_super_actions`) consumed by Swift via `EngineBridge.swift`.

---

## 3. Query Execution Lifecycle

1. **Keystroke Capture**: Swift captures input in `SmoothCaretTextField` with zero UI debounce lag.
2. **FFI Call**: Swift invokes `look_search_json(query)` across the C FFI boundary.
3. **Core Matching & Scoring**:
   - `core/engine` checks active prefixes (`a"`, `f"`, `c"`, `ps"`, `/`, `~`).
   - `core/ranking` computes fuzzy alignment scores.
   - Top-K results are returned as a compacted binary payload.
4. **Native Render**: SwiftUI renders the candidate rows, previews, and icons seamlessly at 120Hz ProMotion refresh rates.
