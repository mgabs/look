# AI & Intelligence

Look includes an integrated intelligence engine designed for speed and local data privacy.

---

## 1. Instant Answer Cards

When typing queries that have no direct local file match, Look concurrently checks quick answer providers:
* **DuckDuckGo & Wikipedia**: Extracts direct definitions, knowledge entity summaries, and facts.
* **Apple Intelligence** *(macOS 15+)*: Falls back to local on-device neural model inference when web search returns no match.
* **Google Suggestions**: Displays live autocomplete rows below query results.

To disable all external network lookups and AI suggestions, set:
```ini
ai_enabled = false
```
in `~/.look.config`.

---

## 2. Conversational Assistant Mode (`>`)

Prefix any query with `>` to enter the interactive AI assistant mode:
* **Meeting Quick Join**:
  - Type `join` to find and launch the nearest upcoming Zoom, Google Meet, Microsoft Teams, or Webex call.
  - Type `join standup` to filter by meeting name.
* **Calendar Management**:
  - `> add lunch tomorrow @ 12pm`: Creates calendar events deterministically without making cloud API calls.
  - `> move dentist to friday`: Modifies existing events with confirmation.
* **Contacts Integration**:
  - `call mom` or `facetime alex`: Resolves phone numbers and email handles from macOS Contacts and launches FaceTime / Messages.
* **Document Summarization**:
  - Highlight or multi-pick (`Cmd+P`) any text file or PDF, then type `> summarize this`.

---

## 3. Privacy & On-Device Guarantees

* **Zero Cloud Lock-in**: Look supports local Ollama models (`http://localhost:11434`) and Apple Intelligence.
* **No Telemetry**: Your queries, calendar contents, clipboard history, and personal contacts are never transmitted to external analytics or ad services.
