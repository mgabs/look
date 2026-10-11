# User Workflow and Shortcuts

## Typical workflow

1. Press `Cmd+Space` to open launcher.
2. Type to search apps, files, folders, or settings.
3. Use `Tab`/`Shift+Tab` or arrow keys to navigate.
4. Press `Enter` to open or execute.

## Important shortcuts

- `Enter`: open selected result / execute command
- `Tab` / `Shift+Tab`: next/previous result or path autocomplete drill-down
- `Up` / `Down`: selection movement
- `Cmd+/`: enter command mode
- `Escape`: back/close (context aware)
- `Shift+Escape`: hide launcher
- `Cmd+Enter`: web search
- `Cmd+F`: reveal in Finder
- `Cmd+C`: copy selected file/folder
- `Cmd+Shift+,`: open/close settings panel
- `Cmd+Shift+;`: reload config
- `Cmd+-`, `Cmd+=`, `Cmd+0`: temporary zoom controls

## Quick system commands

Type `:` prefixed commands in the launcher:

- `:sleep` puts display/system to sleep
- `:lock` locks the screen immediately
- `:mute` toggles system audio mute
- `:theme` toggles system Dark/Light appearance
- `:caff` toggles caffeinate keep-awake state

## Path navigation & fuzzy file jump

- Type `/` or `~` to trigger file-system navigation mode
- Use `Tab` to complete and drill down into subdirectories
- Matches fuzzy file names dynamically

## Command mode

Enter with `Cmd+/`.

Built-ins:

- `calc`
- `shell`
- `kill`
- `sys`

Notes:

- `shell` input containing `sudo` shows an orange warning cue
- `kill` flow requires explicit confirmation

## Clipboard mode

- prefix: `c"`
- fuzzy matching across clipboard items
- `Enter` on clipboard row copies content back to clipboard
- session-scoped in-memory history
