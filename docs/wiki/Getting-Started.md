# Getting Started

## Requirements

- macOS 15.0+ (Sequoia recommended)

## Install

### Homebrew Tap

```bash
brew install --cask mgabs/tap/look
```

Or via direct tap:

```bash
brew tap mgabs/tap
brew install --cask look
```

### Spotlight Shortcut Configuration

If `Cmd+Space` is still opening Spotlight, rebind or disable the Spotlight shortcut:

- `System Settings` -> `Keyboard` -> `Keyboard Shortcuts...` -> `Spotlight`

## First launch notes

If app is unsigned/not notarized, macOS may block first run:

- right-click `Look.app` -> `Open` -> confirm, or
- `System Settings` -> `Privacy & Security` -> `Open Anyway`

## Basic usage

- open launcher with `Cmd+Space`
- type query and press `Enter` to open selection
- `Cmd+F` reveal selected item in Finder
- `Cmd+Enter` web search current query

## Query prefixes & modes

- `a"term` apps only
- `f"term` files only
- `d"term` folders only
- `r"pattern` regex mode
- `c"term` clipboard history mode (fuzzy search enabled)
- `t"text` translate panel
- `tw"text` dictionary lookup panel
- `/path` or `~/path` direct path navigation with Tab completion & fuzzy file jump
- `=expression` or math queries (e.g. `24 * 7`, `100 usd in eur`, `1700000000 timestamp`)
- `:sleep`, `:lock`, `:mute`, `:theme`, `:caff` quick system control commands
