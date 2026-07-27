# Development Log

## Day 4 — All Three Power-Ups & Levels 2-4

**Date:** July 28, 2026

---

## Objective

Build the tutorial band all the way out: Compass (Level 2), Map Fragment + the Map overlay (Level 3), and Warp Scroll (Level 4) — see [PowerUps.md](../PowerUps.md). Levels 1-4 now form a complete, playable tutorial chain.

---

## Accomplishments

### Foundational systems (built once, reused by all three power-ups)

* **`GameState` autoload** (`scripts/autoload/game_state.gd`) — the `GameState` singleton named in Architecture.md's original plan, built now scoped to power-up state only (moves/current-room can join it later when Level 5+ needs them). Tracks per-attempt charges, the currently-armed power-up, visited rooms, known tunnel connections (only ever recorded when a tunnel is actually travelled or Compass-revealed — never just from standing in a room, to keep "the challenge is learning the map" intact), and the Map Fragment snapshot. Everything resets in `start_level()`.
* **First HUD** (`scenes/ui/HUD.tscn` / `scripts/ui/hud.gd`) — a bottom bar of charge-gated buttons (Compass, Map Fragment, Warp Scroll) plus an always-available Map button, a Level/Room label pair, a Continue button, and three overlay patterns: tap-anywhere-to-dismiss (Reveal popup, Map overlay — `mouse_filter = Ignore` so the tap reaches `main.gd`'s world input), and fully modal (Fragment's confirm dialog, the Warp room-picker — default `mouse_filter = Stop`, since they hold buttons that must never be tap-through-able).
* **Room naming** — `RoomData.room_name`, shown in every room via a `RoomLabel`, plus a "Level N" label. Backfilled onto Levels 1-2's rooms too.
* **Level progression** — `LevelData.next_level_path` + a Continue button that appears on level completion; auto-chains Level 1→2→3→4.
* **Player visual** — swapped the placeholder dark square for a yellow circle (readability request), drawn directly via `_draw()`/`draw_circle` rather than a texture asset.

### Level 2 — Compass

Straightforward one-stage lock: tap Compass (forced first), then tap the tunnel (forced second, can't cancel mid-reveal) to learn its destination before travelling it.

### Level 3 — Map Fragment + Map overlay

* Map Fragment snapshots *currently known* tunnel connections and freezes them — travelling further afterward does not retroactively update what the Map shows, per spec.
* Map overlay is a plain text list (visited rooms + known connections), not a graphical map — no room-position data exists anywhere in the project, and a text list matches the existing minimalist style. Tunnel connections render in the tunnel's *actual* color via a `RichTextLabel` with BBCode (`[color=#hex]`), and the room you're currently standing in is bolded "— You are here."
* Three-stage forced sequence in the Library room: tap Fragment → tap Map (to actually see what Fragment did) → tap the tunnel. Fragment alone has no observable effect without being forced to look at the Map right after.

### Level 4 — Warp Scroll

* Start Room has two tunnels; only the wrong one is tappable at first. It leads to a true dead end — zero tunnels, zero doors, nothing to interact with except Warp Scroll.
* Warp opens a room picker (dynamically built list of visited rooms, excluding the current one) and teleports instantly on selection — no tween, since warping destroys the current room and instantiates an unrelated one; there's no shared space to animate across. Charge is spent only on picking a room, not on opening the picker.
* This is the first room in the game revisited mid-attempt with a *different* forced target each time, which needed real architecture work (see below).
* Discussed and deliberately rejected adding a "safety" tunnel back out of the dead end — it would defeat the lesson. Decided as a going-forward rule instead: this dead end is a one-time tutorial exception; every future room should always have at least one real tunnel out, so Warp Scroll stays a convenience ("recovering from inefficient exploration," per the GDD) rather than something required to avoid a stuck game state.

---

## Design Change: `requires_power_up` Moved From `Tappable` to `RoomData`

Originally lived on the specific `Tunnel` node that also happened to be the tutorial's lock target (Levels 2-3). Level 4's dead-end room has **no tappables at all** — nothing to attach the field to — which exposed that the gate was never really about a tappable, it's about the room. Moved it to `RoomData.requires_power_up`, unconditional on whether a lock target even exists. Not a repeat of the old `RoomData.is_exit` mistake (removed in Day 3 for being redundant with scene content and drift-prone) — this field isn't derivable from the scene at all, it's an authorial decision, same category as `move_limit`.

## Design Change: Revisit-Aware Tutorial Locking

Every room built through Level 3 was visited at most once. Level 4's Start Room needed to be visited twice with a *different* forced tunnel each time. Added `Tappable.tutorial_highlight_on_revisit`, and `main.gd` now checks `GameState.get_visited_rooms().has(room_id)` **before** marking the room visited to decide which flag applies. This also forced moving the pulsing-highlight trigger out of `Tappable._ready()` (which only knew its own static flag) and into `main.gd` (which now explicitly calls `set_highlighted(true)` on whichever tappable it picks) — the only place that actually has the attempt history needed to decide.

Ruled out storing "already visited/forced" directly on a `RoomData`/`LevelData` instance: `load()` caches resources by path, so the same instance persists across every replay of a level in one session — mutating it at runtime would leak state across attempts. `GameState`, reset every `start_level()`, is the correct home for anything attempt-scoped.

---

## Bugs Found & Fixed

* **Missing `mouse_filter` on a popup's own container** — `RevealPopup`'s outer `Control` was left at Godot's default (`Stop`), which silently swallowed every tap before it could reach the tap-anywhere-to-dismiss logic in `main.gd`. Its children had the right `Ignore` filter, the container didn't.
* **Input leaking through an `Ignore`-filtered popup onto a hidden button underneath it** — the fix above (using `Ignore` so taps reach world input) has a side effect: a tap can also fall through onto any *other* Control sitting at the same screen position, including HUD buttons the popup is supposed to be covering. Fixed with `hud.gd`'s `_set_buttons_disabled()`, called whenever a tap-anywhere popup opens/closes.
* **Compass could be deselected/skipped mid-tutorial** — tapping Compass again (or tapping empty space) after arming it would silently cancel the forced reveal step, letting the player skip past the lesson. Added a can't-cancel lock during the forced sequence specifically (normal future use can still be cancelled).
* **`_level_complete` blocked popup dismissal, deadlocking the game** — `_unhandled_input`'s very first line returned early whenever the level was complete, which also skipped the Map-overlay dismiss check below it. Since opening the Map also disables the Continue button underneath it, a player who opened Map after finishing a level had no way back — tapping to close Map did nothing, and Continue was disabled. Fixed by moving the `_level_complete` guard below the popup-dismiss checks, so overlays can always be closed regardless of level state.

---

---

## Part 2 — Power-Up Economy, Room Themes, and Level 5

Same day, later session. Picks up the "Next Goal" above: before designing Level 5 itself, resolved the GDD's last open power-up question, then discovered mid-design that room theming needed the same kind of decision.

### Design Change: Power-Ups Become a Persistent Economy, Not a Per-Level Grant

Closes the GDD open question "How many power-ups should players start with, and how are additional ones earned?" (see [GDD.md](../GDD.md#power-up-economy), [PowerUps.md](../PowerUps.md)).

* Each of the three power-ups now has its own **stock, capped at 3**, that persists across the whole game — not reset per level like `GameState._charges` currently does.
* Stock **refills over real time**: ~1 charge per 10 minutes per type, independent timers (no shared pool).
* **Refund on fail:** a charge only leaves stock for good when the level is *completed*. Running out of moves, or quitting/restarting mid-attempt, refunds everything spent that attempt. Chosen specifically to protect the "relaxing, no stress" pillar — a scarce, slowly-regenerating resource that also punishes failed attempts would read like a mobile energy-grind, which the GDD explicitly rules out.
* Rewarded ads that instantly refill a power-up's stock are noted as future scope, not built now.
* **Not yet implemented in code.** `GameState` (`scripts/autoload/game_state.gd`) still resets `_charges` from `LevelData.starting_power_ups` in `start_level()` — that's the Day 4 tutorial-only model. Making stock persistent (save it, timestamp last refill, track attempt-scoped deltas for the refund rule) is deliberately left as a follow-up task; see [TDD.md](../TDD.md)'s new Power-Up Economy System section for the intended implementation shape.

### Design Change: Room Themes Are Per-Stage, Not Per-Room

Original plan (Day 3-ish) was one theme per *room*. Reworked to one theme per *stage* (level), with every room inside that stage individually named from that theme's pool — e.g. Level 5 is a single Library stage, and its rooms are "The Library Entrance," "The Potion Workshop," etc., not a room simply labeled "Library."

* Finalized the 8 themes: 📚 Library, 🗿 Temple, 🌿 Garden, 🧪 Laboratory, 💎 Crystal Chamber, ⚙️ Machinery Room, 🕯️ Shrine, 📦 Storage Room.
* Each theme has a **fixed Start Room name and Exit Room name** (e.g. Library is always "The Library Entrance" → ... → "The Grand Reading Hall"), plus a pool of 10-12 "other room" names for whatever's in between. Full lists in [ArtGuide.md](../ArtGuide.md#room-themes).
* Applied Library to Levels 1-4 retroactively (previously generic "Start Room"/"Exit Room"/"Library"/"Dead End"): Level 3's map-fragment room is now **The Forgotten Archive**, Level 4's dead end is now **The Rare Books Wing**. Levels 1-5 all share the same Library stage, so the player learns the whole game inside one location before Level 6 moves somewhere new.

### Level 5 Design: "Going in Circles"

First level past the tutorial band — see [LevelDesign.md](../LevelDesign.md). 5 rooms (Library theme), 3 tunnel colors, first level with an actual move limit (12, provisional) and no forced power-up gate — the player picks their own path for the first time. One branch off the Start Room never dead-ends, but both of its exits either loop back to the start or take the long way around, teaching "not every tunnel is progress" without punishing the wrong choice hard. Star thresholds (¾/8/12) are provisional pending playtest, matching the GDD's still-open scoring-threshold question.

### Refactor: `RoomTheme` Resource + Role-Based Room Naming

Applying Library to Levels 1-4 by hand (retyping "The Library Entrance" into every level file) would've meant redoing that work by hand again for every future theme change — so this became a data refactor, not just a rename:

* New `RoomTheme` resource (`scripts/data/room_theme.gd`): `start_room_name`, `exit_room_name`, `other_room_names`. One `.tres` per theme under `resources/themes/` — all 8 built now, even though only Library is in use, so future levels can pick one off the shelf with zero extra setup.
* `LevelData` gained a `theme: RoomTheme` field. `RoomData` gained `room_role` (`start` / `other` / `exit`).
* `RoomData.get_display_name(level)` resolves the shown name: `other` rooms use `room_name` directly (unchanged, still a per-level creative pick); `start`/`exit` rooms pull from `level.theme` instead. Swapping a level's theme in the future is now a single reference change — Start/Exit names cascade automatically, no per-room retyping.
* Updated all 7 call sites in `main.gd` that used to read `room_data.room_name` directly to call `get_display_name()` instead. Updated `level_01.tres`–`level_04.tres` to reference `library.tres` and set `room_role` on their Start/Exit rooms, dropping the now-redundant hardcoded `room_name = "Start Room"` / `"Exit Room"` strings.

**Bug found in code review:** the first version of `get_display_name()` claimed `room_name` was a "safety net" fallback if a level had no theme assigned — but the same change had just stripped `room_name` from every Start/Exit room in the `.tres` files, so that fallback would silently return `""` instead. Fixed by making the theme-lookup failure loud instead of silent: `push_error()` plus a visibly-wrong `"(missing room name)"` placeholder, so a future level authored without a theme fails obviously during playtesting instead of showing a blank room title.

**Not tested in-engine.** No Godot install available in this environment — reviewed the `.tres`/`.gd` changes by hand for syntax and consistency, but haven't actually clicked through Levels 1-4 to confirm the renamed rooms display correctly. Worth a playthrough before trusting this fully.

---

## Next Goal

Levels 1-4 (the full tutorial band) are Library-themed and chained together, and Level 5 ("Going in Circles") is designed on paper. Still to do: build Level 5's actual `.tres`/`.tscn` files in Godot; implement the persistent power-up economy in `GameState` (currently still the Day 4 per-level model); design Levels 6-9.
