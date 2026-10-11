# Developer & Contributor Guide

This guide covers building, testing, and debugging Look from source on macOS, Linux, and Windows.

---

## Prerequisites

* **Rust**: Toolchain 1.88+ (`rustup default stable`)
* **macOS Development**:
  - Xcode 16.0+ with Command Line Tools
  - Swift 5.10 / 6.0
* **Linux Development**:
  - GTK3, WebKit2GTK 4.1 (`libwebkit2gtk-4.1-dev`, `libgtk-3-dev`)
* **Tools**:
  - `make`, `cargo`, `sqlite3`

---

## Build Commands

Look provides an orchestrating `Makefile` in the project root:

### Checking Compilation
```bash
# Check all Rust core crates
make core-check

# Check C FFI bridge crate
make ffi-check
```

### Running the App (Development Mode)
```bash
# Builds Rust static lib and launches Look in Debug mode
make app-run
```

### Running Automated Test Suites
```bash
# Run all Rust workspace tests
cargo test --workspace --manifest-path core/Cargo.toml

# Run FFI tests
cargo test --manifest-path bridge/ffi/Cargo.toml

# Run Swift unit tests
cd apps/macos/LauncherApp && swift test
```

### Building Release Packages
```bash
# Build optimized release macOS app bundle and manifest in dist/
make build-release

# Test generating Homebrew formula and cask
make tap
```

---

## Project Structure & Edit Map

* **Native macOS Shell**: `apps/macos/LauncherApp/look-app/`
  - `Support/Launcher/EngineBridge.swift`: FFI bridge client.
  - `Views/Launcher/LauncherView.swift`: Primary search UI container.
  - `Views/Commands/`: Built-in Command mode tools (Pomodoro, Todo, Speed, Shell).
* **Rust Core Engine**: `core/`
  - `core/engine/src/`: Search orchestration, filesystem indexing.
  - `core/calc/src/`: Calculator parser.
  - `core/qactions/src/`: Launchpad grid parser.
* **FFI Interface**: `bridge/ffi/src/`
  - C ABI interface definitions.
* **Homebrew & Packaging**: `Formula/`, `Casks/`, `scripts/`
