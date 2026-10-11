# User Workflow & Shortcuts

## Daily Workflow

1. **Activate**: Press `Cmd+Space` anywhere to summon the launcher.
2. **Search**: Start typing to instantly filter across installed applications, recent files, indexed folders, clipboard clips, and custom sources.
3. **Navigate**: Use `Up` / `Down` arrows or `Tab` / `Shift+Tab` to cycle candidates.
4. **Action**: Press `Enter` to open or execute, `Cmd+Enter` to launch a web query, or `Cmd+F` to reveal the target in Finder.
5. **Dismiss**: Tap `Esc` or `Shift+Esc` to hide the panel and return to your previous app.

---

## Keyboard Shortcuts Cheat Sheet

| Shortcut | Context | Action |
| :--- | :--- | :--- |
| `Cmd+Space` | Global | Show / hide Look launcher window |
| `Enter` | Search Results | Launch selected application or open file |
| `Cmd+Enter` | Search Results | Trigger external web search for the query |
| `Cmd+F` | File / Folder | Reveal selected item in Finder |
| `Cmd+C` | File / Folder | Copy path to system clipboard |
| `Cmd+D` | File / Folder | Move selected file/folder to Trash (recoverable) |
| `Cmd+P` | File / Folder | Toggle item in multi-pick selection basket |
| `Cmd+Shift+P` | File / Folder | Clear all multi-picked items |
| `Cmd+I` | Clipboard row | Paste clip directly into previously active window |
| `Cmd+/` | Main Bar | Enter Command Mode catalog |
| `Cmd+Shift+,` | Any | Open / close Settings panel |
| `Cmd+Shift+;` | Any | Reload `~/.look.config` runtime configuration |
| `Cmd+-` / `Cmd+=` | Any | Adjust launcher UI zoom scale |
| `Cmd+0` | Any | Reset launcher UI zoom scale to 100% |

---

## Query Modes & Prefixes

Type a prefix at the very beginning of the query to restrict or change the search mode:

| Prefix | Mode | Description |
| :--- | :--- | :--- |
| *(None)* | **Unified Search** | Searches apps, files, bookmarks, commands, and math expressions |
| `a"` | **Applications** | Restricts candidates strictly to `.app` bundles |
| `f"` | **Files** | Restricts search to user documents and files |
| `d"` | **Directories** | Restricts search to folders |
| `r"` | **Regex** | Regular expression search across indexed paths |
| `rc"` | **Recent Files** | Shows recently modified or opened disk assets |
| `c"` | **Clipboard History** | Fuzzy search (`fzf` scoring) over recent clipboard text entries |
| `ci"` | **Clipboard Images** | Visual thumbnail gallery of recent screenshot/image copies |
| `t"` | **Translate** | Quick multi-language text translation |
| `tw"` | **Dictionary** | Quick word definition and synonym lookup |
| `ps"` | **Process Manager** | Search running processes by name or listening port (e.g. `ps"3000`) |
| `/` or `~` | **Path Navigation** | Direct file system exploration with `Tab` folder completion |
| `>` | **AI Assistant** | Natural-language conversations, meeting joins, and actions |

---

## Path Navigation & Fuzzy File Jumping

Look includes a filesystem navigation mode:

1. **Activate**: Begin your query with `/` (absolute root path) or `~` (home directory).
2. **Tab Drill-Down**: Press `Tab` when highlighted on a folder to drill down into its subdirectories.
3. **Fuzzy Jumping**: Type partial path components (e.g. `/u/l/b` jumps to `/usr/local/bin`).
4. **Execution**: Press `Enter` to open the file in its default editor or open the directory in Terminal/Finder.
