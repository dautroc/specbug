# Specbug

Specbug is a terminal-native companion for RSpec that blends a familiar “Byebug” feel with an interactive, full-screen test runner. The goal is to help Rubyists navigate, execute, and debug specs without leaving the terminal.

## Concept

The name combines **spec** (RSpec) and **bug** (debugging) to signal a tool that squashes failing tests. Specbug aims to:

- Provide a keyboard-driven, full-screen TUI for browsing and running specs.
- Surface structured test results (status, timing, failures) inline in the UI.
- Drop seamlessly into Byebug when deeper inspection is needed, then restore the TUI after the session ends.

## Recommended Stack

- **TUI layer:** `curses` for a classic full-screen experience, optionally supplemented by TTY Toolkit components (e.g., `tty-reader`, `tty-prompt`, `tty-table`) for input and formatting.
- **RSpec integration:** RSpec Core (>= 3) via `RSpec::Core::Runner` and formatters (e.g., JSON) to discover and run examples, capture structured results, and support repeated runs by clearing example state.
- **Debugging:** Byebug (or the built-in `debug` gem) to step through failing specs. A Pry/Byebug combo is an optional alternative.
- **Process/I/O:** `Open3` or `PTY` to run specs or debug sessions without freezing the TUI; `pastel`, `tty-spinner`, or `tty-progressbar` can enrich output but are optional.
- **Optional utilities:** Thor/Commander for CLI scaffolding and Listen/FileWatcher for a future auto-run mode.

## Architecture Overview

Specbug is organized around three cooperating components:

1. **UI controller** – renders the curses/TTY interface, manages windows/panes, and captures keyboard input.
2. **Test runner** – interfaces with RSpec to discover examples (e.g., `rspec --format json --dry-run`) and execute selected files/examples, returning structured results.
3. **Debugger bridge** – invokes Byebug/debug sessions, suspending the TUI while the debugger owns the terminal and restoring it afterward.

A lightweight controller/observer pattern links these pieces so UI events (run/debug/filter) trigger runner actions, and results stream back into the UI.

## Implementation Phases

1. **Scaffold the TUI**: Initialize the curses/TTY screen, basic menu, and navigation (arrow keys, enter). Validate keyboard handling and rendering.
2. **Wire RSpec**: Discover specs (via JSON dry-run or RSpec metadata) and render them as a navigable tree. Run selected files/examples and present statuses, durations, and failure details.
3. **Add Debugging**: Let users trigger Byebug on a chosen example or line. Suspend the curses screen while the debugger runs; on exit, rehydrate the TUI.
4. **Refine UX**: Color-code statuses, add filtering (e.g., failures-only), scrolling/paging, multi-select runs, and resilient error handling so terminal state is always restored.
5. **Document & Package**: Provide help/README content, consider a `.specbug` config, add self-tests, and prepare gem packaging for distribution.

## Operational Notes

- Favor in-process RSpec runs for speed but clear examples between runs to avoid state bleed.
- For debugging, a child process or PTY avoids curses conflicts and mirrors Byebug’s native CLI feel.
- Keep global state minimal; prefer passing events/results through small, testable interfaces.

## Getting Started

An initial scaffold is available in `bin/specbug` with supporting code in `lib/specbug`. To try the prototype:

1. Install dependencies:

   ```sh
   bundle install
   ```

2. Run the TUI from your project root (it will look for specs in `spec/`):

   ```sh
   bundle exec bin/specbug
   ```

Controls are intentionally minimal for the first cut:

- **↑ / ↓** to move between discovered spec files.
- **Enter** to run the highlighted spec via RSpec.
- **q** to quit and return to the shell.

Future iterations will add richer panes (example-level navigation, failure output, debugger hand-off), but this scaffold provides a working loop for discovering and executing spec files from a curses-driven interface.
