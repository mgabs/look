# Spec Delta

## Purpose
The `/emoji` command lets users search for an emoji by name or keyword and copy it or insert it into the previously focused app, on macOS and linows, using search logic shared through `core/emoji`.

## ADDED Requirements

### Requirement: REQ-EMOJI-1 Shared search
The system MUST provide emoji search from a single shared `core/emoji` crate, used by both macOS and linows, returning emoji whose name or keywords match the query case-insensitively.

#### Scenario: Match by name
- **GIVEN** the `/emoji` panel is open
- **WHEN** the user types "smile"
- **THEN** results include emoji whose name or keywords contain "smile"
- **AND** macOS and linows return the same results for the same query

#### Scenario: Match by keyword
- **GIVEN** the `/emoji` panel is open
- **WHEN** the user types a keyword that is not part of an emoji's name
- **THEN** emoji carrying that keyword are returned

### Requirement: REQ-EMOJI-2 Command panel
The system MUST register `/emoji` as a command on macOS and linows that opens a panel with a search input and a result list, in the same way as `/calc` and `/pomo`.

#### Scenario: Open panel
- **GIVEN** the launcher is open
- **WHEN** the user enters `/emoji`
- **THEN** the emoji panel opens with the search input focused

### Requirement: REQ-EMOJI-3 Copy on Enter
The system MUST copy the selected emoji to the clipboard when the user presses Enter, and MUST show visible confirmation.

#### Scenario: Copy selected emoji
- **GIVEN** a result is selected
- **WHEN** the user presses Enter
- **THEN** the emoji is on the clipboard
- **AND** the panel shows a confirmation

### Requirement: REQ-EMOJI-4 Insert on Shift+Enter
The system MUST insert the selected emoji into the previously focused app when the user presses Shift+Enter, by copying it, dismissing the launcher and issuing a paste through the existing platform paste helpers.

#### Scenario: Insert into previous app
- **GIVEN** a result is selected and paste is permitted
- **WHEN** the user presses Shift+Enter
- **THEN** the launcher hides
- **AND** the emoji is pasted into the previously focused app

#### Scenario: Insertion unavailable
- **GIVEN** a result is selected and insertion is not permitted (for example macOS Accessibility is denied)
- **WHEN** the user presses Shift+Enter
- **THEN** the emoji is copied to the clipboard
- **AND** the user is told it was copied instead of inserted

### Requirement: REQ-EMOJI-5 Recents
The system MUST record each emoji the user copies or inserts in a recents list, show recents when the query is empty, order them most recent first, cap the list at 20 entries, and persist it across restarts.

#### Scenario: Recents after use
- **GIVEN** the user copied an emoji
- **WHEN** the user reopens `/emoji` with an empty query
- **THEN** that emoji appears first in the list

#### Scenario: Recents survive restart
- **GIVEN** recents exist
- **WHEN** the app is restarted and `/emoji` is opened
- **THEN** the same recents are shown

#### Scenario: Recents cap
- **GIVEN** 20 recents exist
- **WHEN** the user uses a new emoji
- **THEN** the oldest entry is dropped

### Requirement: REQ-EMOJI-6 Empty and no-match states
The system MUST show recents (or an empty hint when there are none) for an empty query, and a no-results message for a query with no matches, without error.

#### Scenario: No match
- **WHEN** the user types a query matching nothing
- **THEN** the panel shows a no-results message
- **AND** Enter and Shift+Enter do nothing

### Requirement: NFR-EMOJI-1 Search latency
Search over the bundled dataset MUST return results in under 20 ms per keystroke on supported hardware, with no network access required.

#### Scenario: Latency budget
- **WHEN** a query is run against the full dataset
- **THEN** results return within 20 ms
- **AND** no network request is made

## Review Gate
- [x] **Gate 2 Approval**: Specifications reviewed and approved by human before technical design.
