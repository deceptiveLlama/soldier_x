# Before anything else
- Always be critical and challenge ideas.
- Use common knowledge, and standard, well tested and proven game design/programming practices.
- If anything in conversations with between assistant and user doesn't align with this claude.md file, ask for confirmation. The file may need updating, or it may be a mistake.
- When the user asks "does it make sense?" or similar questions, they are asking genuinely — not stating truths or being assertive. Always answer honestly.

# Soldier X — Overwatch Workshop (OverPy)

## What is Soldier X?
- A custom game mode in Overwatch. A PvP First Person Shooter up to 7 players with a Deathmatch configuration (first to 100 kills win).
- Players gain xp to level up by dealing damage, scoring eliminations and picking up dropped xp orbs.
- When gaining a level, players can learn 1 out of 3 talents in the shop. The available talents are randomized on each shop entry.
- The game mode has a PvP First Core Pillar, but bots are there to make empty servers more enjoyable until more players join.

## Platform Limits
- Maximum of 128 global variables, 128 player variables, and 128 subroutines.
- Total element count (rules, conditions, actions, and values) can't exceed 32768.
- Maximum of 128 texts and 128 effects during runtime; adding more deletes the oldest one automatically.
- Arrays are limited to 1000 elements per dimension (index 0-999).
- `wait()` has a minimum resolution of 0.016s (one tick). Any `wait()` value below 0.016 is rounded up to one tick. When dividing intervals across players (e.g., serialized operations), ensure the per-player wait stays >= 0.016s.

## OverPy Patterns
- For-loop variables must be plain variables (not `#!defineMember`).
- Chasing an array or value at array index is not possible — it must be a plain variable. The chased variable can be stored in an array though.
- Use `i`, `j`, `k` as global iterator variables for loops without waits. Use dedicated named variables for loops that contain waits. During `wait()`/`waitUntil()`, other rules can overwrite shared iterators.
- Use descriptive names in list comprehensions (e.g., `node`, `edge`, `neighbor` — not `n`, `e`). No nested list comprehensions — OverPy doesn't support them. Use for loops instead.
- Workshop values cannot nest more than 1 level deep. Break complex expressions into precomputed variables instead of nesting sorts/filters/lambdas inside each other.
- For-loops don't always need waits. If the game crashes or behaves unexpectedly, investigate whether a loop is too heavy or running infinitely — add waits only where needed.
- Subroutines:
	- `subroutine_name()` (Call Subroutine) — blocks the calling rule until done.
	- `async(subroutine_name, AsyncBehavior.NOOP/RESTART)` (Start Rule) — runs in parallel, inherits caller's context (event player). RESTART only kills that player's instance, not other players'.
	- Prefer `async()` over rules with `@Condition` when the trigger point is known in code. Rules check conditions every tick while false (ongoing cost); `async()` only runs when triggered.
	- **RESTART + wait() = crash risk (confirmed stack overflow).** Each RESTART that interrupts an active wait() pushes onto a shared global stack. At ~465 accumulated interrupted waits, the server crashes. The stack is shared across ALL subroutines. Wait duration doesn't matter — only whether the wait is still active when RESTART fires. If the wait completes before the next RESTART, it does NOT count toward the stack.
	- **Rule: subroutines with wait()/waitUntil() inside MUST use AsyncBehavior.NOOP, never RESTART.** If NOOP doesn't preserve the design intent, restructure the logic (e.g., use @Condition rules, inline into the caller, or make the subroutine react to state changes internally instead of being restarted).

## Naming Conventions
- Avoid single-letter abbreviations in variable/function names. Exceptions: `i`, `j`, `k` as loop iterators.
- Debug-only variables must follow `debug_<feature>_...` naming (e.g., `debug_bot_stuck`, `debug_srv_load_sum`). A variable is debug-only if it is ONLY reachable/visible when spectating (hostPlayer, not on hero Soldier:76). Variables accessible during gameplay are NOT debug.
- `current_X` prefix = THE instance of X we're actively working with. The value itself is what we care about, not a step toward computing something else. Distinct from iterators (`i`, `j`, `k`) and intermediate calculations (`X_result`, `X_hit`).
- `#!defineMember` in Declarations.opy creates a named alias pointing to an array index (e.g., `variable[93]` or `global_variable[5]`). The index `[N]` is **required** — omitting it maps to the raw variable, not an auto-assigned slot. This extends beyond the 128 plain variable limit — array indices go up to 999 (needs confirmation). Limitations: cannot be chased, cannot be used as a for-loop iterator.

## Performance
- Element count and server load are constant concerns, and all code has to be designed with a "performance-first mindset".
- Gate expensive operations behind cheaper checks when possible.
- Store repeated moderately-to-heavy calculations in a variable for reuse instead of recalculating.
- Workshop actions with reevaluation (throttle, facing, effects, HUD texts, etc.) should be started once. Control their behavior by updating the variables they reference, not by calling stop/start repeatedly. This reduces element count and server load.
- Precompute expensive filtering/calculations once at game start (or map init) and store the results in a reusable variable/array, but only for data that won't change during the match. If the data depends on dynamic state (e.g., player count, destroyed objects), either recompute when the state changes or don't precompute.
- When multiple code branches need the same data, compute it once before the branching and store in a variable. Don't duplicate the same calculation inside each branch.

## Code Organization
- Avoid code duplication.
- Each variable must have one clear purpose — never reuse a variable for a different data type or meaning in a different context.
- When logic needs to run across multiple code paths (e.g., different attribute handlers in the walk loop), prefer a separate async subroutine that sets a shared variable, rather than duplicating the logic inside each branch. The branches then react to the variable. This avoids code duplication and ensures consistent behavior regardless of which branch is active.
- Merge rules that share the same event type into a single rule to reduce element count and rule-checking overhead. This applies to: global init rules (no @Event), player init rules (@Event eachPlayer with init-like conditions), @Event playerDied, @Event playerDealtDamage, @Event playerTookDamage, @Event playerLeft, @Event playerEarnedElimination, and any other shared event triggers. Rules with different @Hero or @Team filters can be merged using if/else branches (e.g., `if eventPlayer.isDummy()` to separate bot vs player logic).
	- Exception: debug rules (kept separate for easy identification/removal).
- **File-level debug exclusion:** Debug files (`debug - development.opy`, `debug - release.opy`) can be excluded by commenting out their `#!include` in soldier_x.opy for a clean release build. To maintain this:
	- Non-debug files (bots, soldier_x, etc.) must have ZERO hudText/createInWorldText debug calls. They only set flag variables (e.g., `debug_bot_stuck = true`).
	- Debug files contain ALL debug rules, Workshop Settings, and visual output. They react to flags via `@Condition` rules.
	- All debug variables are declared in Declarations.opy as plain globalvars/defineMember (no Workshop Settings). Debug files assign Workshop Settings in init rules, overriding the defaults when included.
	- When debug files are excluded: flag variables are set but never read (harmless), Workshop Settings default to 0/false, zero debug output.
- **Variable declarations:** Variables used in only one file should be declared in that file. Variables used across multiple files should be declared in Declarations.opy. Move to Declarations when a variable starts being referenced from a second file.

## Debugging & Workflow
- Do not solve issues by guessing. Debugging/asserts use hudText(), createInWorldText(), or bigMessage(). Then ask for the values shown on screen.
- Assert ownership — orange is the assistant's color:
	- **Orange** = assistant-owned. Add/change/remove freely for debugging. Both evalOnce and non-evalOnce.
	- **Any other color** = user-owned. NEVER remove the code without explicit user permission.
	- **Non-evalOnce** hudTexts (live-updating): sortOrder 1 — always visible above snapshots. WARNING: non-evalOnce texts update every tick and are NOT reliable as a source of truth for debugging — they can change too fast to observe. Use evalOnce with timestamps for capturing actual execution flow.
	- **evalOnce** hudTexts (snapshots): sortOrder 2. Store ID with `debug_texts.append(getLastCreatedText())` for clearing via spectator button (Move Up + Move Down). These are the reliable source of truth — they capture a frozen moment with timestamp and execution order.
	- User-owned hudTexts visible only when spectating: use `hudText(hostPlayer if hostPlayer.getCurrentHero() != Hero.SOLDIER else null, ...)` with `SpecVisibility.ALWAYS`.
	- All debug hudTexts: text goes in subheader (2nd field), leave header as null. Place on left side (HudPosition.ACTUALLY_LEFT). Include timestamp via getTotalTimeElapsed().
	- When a bug can be debugged on one bot and happens often enough (if unsure — ask), gate asserts behind `eventPlayer == debug_selected_player` to avoid spamming from all bots. Format: `"[{timestamp}] [Selected] [Bot{slot}] ..."` — the `[Selected]` tag indicates the assert only triggers from the selected bot.
	- createInWorldText(): Best for showing WHERE something happens. Orange = assistant-owned, any other color = user-owned. If related to a bot, create once and toggle visibility.
	- bigMessage(): Useful for confirming a single event happened. Stays on screen for 5 seconds.
- Always use Beam.BAD for debugging.
- Debug effects dependent on individual bot positions should be created once during init with visibility reevaluated based on fitting conditions. If unclear, ask for clarification.
- Always explain proposed changes before making them.
- Wait for confirmation before editing files.
- Always suggest additions to this claude.md file when conversations reveal information that would improve future communication.

## Resources
- Analyze (whenever needed) "OverPy ReadMe - Syntax - Functions - Tips and Tricks.pdf" for OverPy syntax, functions, and tips and tricks.
- Browse https://workshop.codes/wiki for Overwatch Workshop information
