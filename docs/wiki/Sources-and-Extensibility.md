# Custom Sources & Extensibility

Look reads every `.toml` file in `~/.look/sources/` (override with `LOOK_SOURCES_DIR`). Needs Look v0.6.12+. No scripts or plugins required.

Full reference: [`docs/user-sources.md`](https://github.com/mgabs/look/blob/main/docs/user-sources.md). Ready-made examples: [lookbook](https://github.com/kunkka19xx/lookbook).

## Quick start

```bash
mkdir -p ~/.look/sources
$EDITOR ~/.look/sources/mine.toml
```

```toml
[projects]
name = "Projects"
dir  = "~/dev"
only = "dirs"

[work]
name = "Work setup"
do = [
  "open -a Slack",
  "open -a Safari https://github.com",
]
```

Reload: `Cmd+Shift+;` (macOS) / `Ctrl+Shift+;` (Linux, Windows).

- Type `projects` → your repos.
- Type `work setup` → one Enter runs both commands.

## Notes

- Any number of files; block ids must be unique across the whole directory.
- Block kinds (`do`, directory listings, and more) are documented in the full reference.
- Keep sources in a dotfiles repo by pointing `LOOK_SOURCES_DIR` at it.
