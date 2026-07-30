# Development Log

## Day 7 — Persistent Power-Up Economy

**Date:** July 31, 2026

---

## Objective

Build the persistent power-up economy from [PowerUps.md](../PowerUps.md#economy) — flagged as deferred back in [DevLog 004](004-Power-Ups-And-Levels-2-4.md) and again in [DevLog 005](005-Move-Counter-And-Level-5.md), since neither Levels 2-4 nor Level 5 needed it to be playable. By Level 6/7 it's worth doing for real: stock that carries across levels, refills over real time, and gets refunded on a failed or retried attempt.

Scope note: this is in-memory persistence across levels *within a running session*, not save-to-disk persistence across app restarts. That's a separate, bigger feature GDD.md already lists as future save data (highest level, star ratings, best moves, power-up stock *and* last-refill time). This system is built so that future save/load only has to serialize `_charges` and `_last_refill_time` — nothing about today's design assumes in-memory-only.

---

## `GameState` Changes

Power-up stock used to be a per-level grant: `start_level()` cleared `_charges` and set it from `LevelData.starting_power_ups` every time. That's gone — stock now lives for the whole session.

* **`LevelData.starting_power_ups` changed meaning.** Its keys used to set a charge count; now they just mark which power-up types are *unlocked* (visible/usable) from that level on, matching the scripted introductions in Levels 2-4. The `.tres` files didn't need to change — the values in `{"compass": 1}` etc. are simply unused now, iterating the dictionary's keys works the same either way.
* **`get_charges()`** returns 0 for a type that isn't unlocked yet (so Compass/Fragment/Warp stay hidden pre-introduction, same as before), otherwise lazily catches stock up via `_apply_refill()` before returning it. New players effectively start with 3 of each (the `Dictionary.get(id, MAX_STOCK)` default) — they just can't see or spend it until unlocked.
* **`_apply_refill()`** is the real-time refill: 1 charge per 10 minutes per type, capped at 3, computed lazily whenever `get_charges()` is called rather than ticking every frame. It carries over leftover fractional time instead of rounding it away, and only tracks a `_last_refill_time` entry for a power-up while its stock is below max — once full, there's nothing to accrue.
* **`consume()`** now also records the spend into `_spent_this_attempt`, and starts the refill clock at the exact moment stock first drops below max (not on every subsequent spend — that would keep restarting the timer and stall the refill).
* **`end_attempt(completed: bool)`** replaces the old blanket per-level reset. `main.gd` calls it with `true` the moment the exit door opens (spend was real, nothing to refund) and with `false` the moment a level fails from running out of moves (refunds every charge spent that attempt, capped back at 3). Retry re-enters `start_level()` afterward with stock already restored — no separate refund path needed there.

---

## Known Gaps

* **Quitting mid-attempt** (closing the app, or any future "back to menu") isn't refunded, since there's no such flow yet to hook `end_attempt(false)` into. Not a regression — this case didn't exist before either.
* **Not tested in-engine**, same caveat as every level built so far.

---

## Refinement: Tutorial Doesn't Spend Real Stock, Charge Counts Are Visible

Two corrections made right after the first pass above, before any playtesting:

* **`consume()`** now also checks `not has_unlimited_moves()`. Levels 1-4 (the tutorial band) are exactly the levels with unlimited moves, so this reuses that existing signal instead of adding a level-number special case. Practically: using Compass/Fragment/Warp during the scripted tutorial introductions no longer spends from the real stock at all — it's a free demonstration. Real spending starts at Level 5, the first level with a move limit, so every player reaches it with the full 3 of each, never fewer. Updated [PowerUps.md](../PowerUps.md#economy) and [GDD.md](../GDD.md#power-up-economy), which previously said "2 of each by Level 5" — that assumed tutorial spending was permanent, which it no longer is.
* **Charge counts are now visible.** `HUD.set_compass_charges()` / `set_fragment_charges()` / `set_warp_charges()` put the current count directly on each button's text (e.g. "Compass (2)"), updated both on room load and live via the existing `charges_changed` signal. Closes the gap flagged above — a player can now actually see their stock instead of only seeing a button appear or disappear at zero.

---

## Bug Found in Playtest: Old Power-Ups Bled Into Later Tutorial Levels

Caught live: with stock persistent, Compass (unlocked at Level 2) stayed visible in Levels 3 and 4 too, and Map Fragment (unlocked at Level 3) stayed visible in Level 4 — because "unlocked" is now permanent by design. This broke a rule the tutorial band depends on: each level is supposed to teach exactly one mechanic at a time, not show every mechanic learned so far.

Fix: `main.gd` gained `_is_power_up_shown(power_up_id)`. During the tutorial band (`GameState.has_unlimited_moves()`), a power-up is only shown if it's a key in *that level's own* `starting_power_ups` — i.e., the one mechanic that level itself introduces — regardless of what's unlocked from earlier levels. From Level 5 on (real moves), the check drops back to plain "has real stock," so every previously-learned power-up shows normally and no future level needs to re-declare `starting_power_ups` just to keep a button visible. Both `_on_room_loaded` and `_on_powerup_charges_changed` now route through this one helper instead of checking raw charge counts directly.

---

## Bug Found in Playtest: Visible Power-Up Buttons Were Still Clickable Off-Script

Follow-up catch: being *visible* wasn't the whole story — during the tutorial band, whichever power-up was visible could still be pressed at any time, not just when the tutorial was actually asking for it. Concretely, Fragment (Level 3) and Warp (Level 4) become visible the instant their level starts (unlocked in `GameState.start_level()`), but the room that actually needs them — the one with `requires_power_up` set — often isn't the first room the player sees. A player could press Fragment from the Start room before ever reaching the Forgotten Archive, which would burn the "no portals discovered yet" confirm dialog and unlock the Map early, well ahead of where the tutorial script means to reveal it.

Fix: added `_is_power_up_enabled(power_up_id)` alongside `_is_power_up_shown()`. During the tutorial band it only returns true for whichever power-up `_tutorial_awaiting_power_up` currently names — i.e., exactly the one the tutorial is telling the player to use right now — everything else stays visible-but-locked (`Button.disabled = true`) instead of just visible. From Level 5 on it's always enabled, same as before.

This touches `Button.disabled` on the same three buttons that `HUD._set_buttons_disabled()` (popups) and `set_utility_buttons_disabled()` (level complete) also touch, so a new `_refresh_power_up_buttons()` helper re-applies the tutorial gate at every point one of those blanket toggles could otherwise stomp on it: after the Compass/Fragment/Warp presses that clear `_tutorial_awaiting_power_up`, and after the Reveal popup and Map overlay close (the two popups that blanket-re-enable all buttons on dismiss). Warp's own confirm/cancel picker and the Fragment confirm dialog don't blanket-toggle buttons at all, so they didn't need a hook.

---

## Recharge Countdown

Added a visible countdown under each power-up button (e.g. "4:32") so the player can see how long until the next charge, instead of the button just silently reappearing usable later.

* **`GameState.get_seconds_until_next_charge(power_up_id)`** mirrors `_apply_refill()`'s math: 0 if not unlocked or already at `MAX_STOCK` (nothing accruing), otherwise `REFILL_INTERVAL_SECONDS` minus elapsed time since `_last_refill_time`.
* **`HUD`** gained `CompassTimerLabel` / `FragmentTimerLabel` / `WarpTimerLabel`, one under each button, shown only while their power-up has a countdown running.
* **`main.gd`** runs a 1-second repeating `Timer` (created in code, no scene changes needed) that calls `_refresh_power_up_buttons()` so the countdown ticks live. The tick skips itself whenever something else is deliberately holding the buttons locked — level complete, level failed, the Reveal popup, or the Map overlay — so it can't undo those states the same way the tutorial-gate fix above had to guard against.

---

## Fragment Now Confirms Its Own Use

Compass gives clear feedback when used (the Reveal popup, "Leads to X"), and Warp is obviously used because the room changes — but Fragment did its work silently. The only visible sign was the charge count ticking down on the button, which made it hard to tell whether a press actually did anything.

Fix: `_use_map_fragment()` now shows the same Reveal popup Compass uses, every time it's actually used — "Map Fragment used. Your explored connections are saved to the map." if there was something to capture, or a "nothing was saved — you haven't explored any connections yet" variant if used anyway with nothing known. The existing pre-use warning (the "no portals discovered yet — use anyway?" confirm dialog) is unchanged; this adds the missing post-use confirmation, not a replacement for it.

---

## Level 5+: Disable at 0 Charges Instead of Hiding

From Level 5 on, running a power-up down to 0 charges used to hide its button entirely (same rule that was hiding *unlocked* buttons). That's wrong specifically for Level 5+: hiding the button also hides the recharge countdown underneath it, so a player who spent their last charge had no way to see it still existed or when it'd come back — only during the tutorial band does "hide it" make sense (it isn't relevant yet at all).

Fix: `_is_power_up_shown()` now only hides a power-up when it isn't unlocked yet (`GameState.is_unlocked()`, new) — once unlocked, Level 5+ always shows it. `_is_power_up_enabled()` now does the charge check instead: enabled only while `get_charges() > 0`. Net effect: from Level 5 on, a depleted power-up stays visible, greyed out (Godot's default disabled button styling), with its recharge countdown still ticking underneath — exactly what used to disappear. The tutorial band's visibility rule (Levels 1-4, gated on that level's own `starting_power_ups`) is unchanged.

---

## Code Audit

Read back through `game_state.gd`, `main.gd`, and `hud.gd` in full — everything this session touched — looking for bugs, redundant work, and naming inconsistencies. No behavior-changing bugs found; three cleanups applied:

* **`LevelData.starting_power_ups` renamed to `power_up_unlocks`, and its type changed from `Dictionary` to `Array[String]`.** The Dictionary's int values (`{"compass": 1}`, `{"compass": 3, ...}`) stopped meaning anything the moment stock became persistent earlier this devlog — only the keys were ever read. An `Array[String]` says what the field actually is now: a plain list of power-up ids to unlock, not a set of charge grants. Updated all 6 level files that set it (`level_02` through `level_07`), `LevelData`, `GameState.start_level()`, and `main.gd`'s `_is_power_up_shown()` — verified with a full-project grep afterward that no reference to the old name or the old Dictionary shape survived, including in a stale doc-comment in `game_state.gd` and a pre-implementation "Decision" writeup in `TDD.md`.
* **`GameState.consume()` no longer re-reads `_charges` three times.** It called `get_charges()` once and then `_charges.get(power_up_id, MAX_STOCK)` twice more for the same value. Now it caches `get_charges()`'s result once and reuses it, and the tutorial (unlimited-moves) early-out is a plain early `return` instead of being folded into the main `if` condition — reads closer to the doc comment above it ("tutorial doesn't spend") than the compound condition did.
* **`main.gd` avoided repeat `GameState.get_charges()` calls per power-up per refresh.** `_refresh_power_up_buttons()` was calling `get_charges()` up to 3 times per power-up (once directly, once inside `_is_power_up_shown()`, once inside `_is_power_up_enabled()`) every time it ran — including every second, from the recharge-countdown timer. `_is_power_up_shown()`/`_is_power_up_enabled()` now take the charge count as a parameter instead of re-querying it, so it's fetched once per power-up per refresh. `_on_power_up_charges_changed()` (renamed from `_on_powerup_charges_changed`, matching the `power_up` spelling used everywhere else in this file) already had the fresh value as its `remaining` parameter, so it needed zero `GameState` calls at all, not fewer. None of this was ever a real performance problem — three extra dictionary lookups a second is immeasurable — but it's clearer with one obvious source of truth per value instead of three call sites that could in principle disagree.

**Deliberately not done:** collapsing the repeated compass/fragment/warp blocks (in `_refresh_power_up_buttons()`, `_on_power_up_charges_changed()`, and HUD's setter methods) into a single data-driven loop over a list of power-up ids. PowerUps.md is explicit that there are exactly three power-ups in Version 1.0, each with its own `@onready` node reference and (for Compass) genuinely different behavior around arming. A generic loop would trade that explicitness for a small reduction in repeated lines, and — without Godot installed to actually run it — more ways for a typo in a string-keyed lookup to fail silently instead of at edit time. Not worth it for three items that aren't expected to grow.

---

## Status

Closed. Most of the fixes above (tutorial bleed-through, off-script clicking) were caught through actual in-engine playtesting, not just review — the two most recent changes (Level 5+ disable-vs-hide, Fragment's confirmation popup), plus everything in the Code Audit section, haven't been separately clicked through yet, so still worth a full pass before trusting all of it.

---

## Next Goal

Code audit across the systems touched this session (`game_state.gd`, `main.gd`, `hud.gd`) — refactor and simplify where it makes sense, check against GDScript best practices. Then continue with Levels 8-10 design (new theme, first real difficulty step up).

---
