# Development Log

## Day 5 — Move Counter, Level Failure, and Level 5

**Date:** July 29, 2026

---

## Objective

Build Level 5 ("Going in Circles," see [LevelDesign.md](../LevelDesign.md)), the first level past the tutorial band. Doing that honestly required closing a gap first: `LevelData.move_limit` existed as a data field since Day 1, but nothing in code actually counted moves, showed them in the HUD, or failed the level at zero — Level 5 is specifically "the first move-limited level," so without that system its defining mechanic wouldn't exist in-game.

---

## Also Renamed: Tunnel → Portal

Earlier the same day, the game's teleport mechanic and title were renamed from "Tunnel" to "Portal" across docs, design, and code (the working repo/folder name stays `TunnelEscape`). `tunnel.gd` → `portal.gd`, class `Tunnel` → `Portal`, `scenes/tunnel/` → `scenes/portal/`, signal `tunnel_entered` → `portal_entered`, and all doc/UI copy updated to match. Mentioned here only because every system touched below is written in terms of `Portal`, not for its own sake.

---

## Move Counter & Level Failure System

* **`GameState`** gained `move_limit`/`moves_remaining`, set from `LevelData.move_limit` in `start_level()`. `has_unlimited_moves()` (`move_limit < 0`, same convention Levels 1-4 already used for "no limit"), `consume_move()`, and `is_out_of_moves()` round out the API.
* **`main.gd`** calls `GameState.consume_move()` in `_on_portal_entered` — matching the existing TDD.md decision that only entering a portal costs a move, not tapping the exit door. Moves label refreshes immediately on tap and again on room load.
* **Failure check** lives in `_on_room_loaded`: if `GameState.is_out_of_moves()` and the room just entered isn't the exit room (`room_data.room_role != "exit"`), the level fails. This deliberately does **not** fail the player who spends their last move entering the exit room itself — they still get to tap the (free) door.
* **HUD** gained a `MovesLabel` (top bar, per the GDD's UI spec) and a `FailOverlay` (full-screen, "Out of moves!" + Retry), styled the same modal way as `FragmentConfirmDialog`. New `retry_pressed` signal.
* **Retry** reuses `_start_level()` against a newly-tracked `_current_level_path` (previously only the very first level's path was stored anywhere) — restarting is just re-running the same level-start flow, not a separate code path.
* `_level_failed` gates `_unhandled_input` the same way `_level_complete` already did, so a failed room can't be tapped through — only the Retry button (a HUD button, not world input) gets you out.

**Not implemented:** the persistent power-up economy (stock across levels, real-time refill) that PowerUps.md assumes is still active by Level 5 — flagged already in [DevLog 004](004-Power-Ups-And-Levels-2-4.md) as a follow-up, deliberately deferred again here. Level 5 doesn't require power-ups to solve, so this doesn't block it; it means a fresh playthrough currently reaches Level 5 with 0 charges of everything instead of the ~2-3 the design assumes.

---

## Level 5: "Going in Circles"

Built exactly per [LevelDesign.md](../LevelDesign.md)'s connection table: 5 rooms, all Library-themed (last level of that theme), 3 portal colors, `move_limit = 12`, no forced power-up gate — first level where the player picks their own path.

* `room_05_start.tscn` (Library Entrance) — Red → Potion Workshop, Green → Scriptorium.
* `room_05_potion_workshop.tscn` — Yellow → Exit, Green → Vault.
* `room_05_scriptorium.tscn` — Red → Vault, Yellow → Start (loops back).
* `room_05_vault.tscn` (Ancient Records Vault) — Red → Exit, Green → Start (loops back).
* `room_05_exit.tscn` (Grand Reading Hall) — plain `ExitDoor`, no forced highlight (nothing in Level 5 is tutorial-locked).
* `level_05.tres` ties them together via the existing `RoomData`/`LevelTheme` pattern; no code changes needed to author it, confirming the Day 4 data-driven pipeline holds up unmodified for the first non-tutorial level.
* Wired `level_04.tres.next_level_path` to `level_05.tres` (previously blank, since Level 5 didn't exist yet).

Fastest route (Red, Yellow) finishes in 2 moves; a longer valid route (Green, Red, Red) finishes in 3 — matches the design doc's worked example exactly.

---

## Star Rating System

Wired up the star thresholds LevelDesign.md already documented for Level 5 (⭐⭐⭐ ≤4, ⭐⭐ ≤8, ⭐ ≤12) — no level had a scoring system in code until now.

* **`LevelData`** gained `star_3_threshold`/`star_2_threshold` and `get_star_rating(moves_used)`. Levels with no move limit or no thresholds authored (Levels 1-4, so far) always return 3 stars — matches the doc's methodology, which only applies to move-limited levels.
* **`GameState`** gained `get_moves_used()` (`move_limit - moves_remaining`).
* **`level_05.tres`** set to `star_3_threshold = 4`, `star_2_threshold = 8`, matching LevelDesign.md exactly.
* **`main.gd`**, on level completion, computes the rating and passes it to a new `HUD.show_stars()` (e.g. "⭐⭐⭐ (3 moves)"), shown next to the Continue button and cleared on the next room load.

## Bug Found in Playtest: Utility Buttons Stayed Live After Completion

First in-engine playthrough (Levels 1 through 5, in order) caught a real bug: the Compass, Fragment, Warp, and Map HUD buttons are plain `Button` nodes wired straight to signals, so they kept working even after a level finished. Worst case, the Warp button let the player pick a room from `LevelLoader.enter_room()` directly, which re-fires `_on_room_loaded` and silently resets `_level_complete` back to `false` — a player could warp right out of a "finished" level.

Fix: `HUD.set_utility_buttons_disabled()` locks all four buttons the moment `_on_door_opened` fires, and `_on_room_loaded` unlocks them again on the next room — whether that next room comes from Continue or Retry.

**Tested in-engine.** Played Levels 1 through 5 in order via the normal in-game flow. Move counter, fail overlay, retry, and the new star rating all confirmed working; the button lockout bug above was found and fixed during this pass.

---

## Next Goal

Implement the persistent power-up economy (still outstanding since Day 4), and design Levels 6-9.
