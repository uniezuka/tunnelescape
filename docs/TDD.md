# Technical Design Document (TDD)

## Overview

Technical companion to the [GDD](GDD.md). Tracks engine choice, core systems, and open implementation questions as they get resolved during prototyping.

## Engine & Tooling

* **Engine:** Godot 4
* **Language:** GDScript
* **Editor:** VS Code
* **Version Control:** Git
* **Target Platform:** Android

## Systems

### Movement System

**Decision:** Tap-to-move. Player taps a tunnel or the exit to act; no free walking inside a room, no tile-grid movement. Simpler on touch, and maps cleanly onto the move-counter model (1 move = 1 discrete action).

### Tunnel/Teleportation System

Since movement is tap-to-move (no free walking, no physical collision), a tunnel is a tappable node in the room scene, not a trigger the player walks into.

Flow on tap:

1. Tunnel node emits a signal (e.g. `tunnel_entered(destination_room_id)`).
2. Room/level controller looks up the destination room from the level's data (see Data Structures).
3. Move counter decrements by 1.
4. Current room scene is swapped for the destination room scene (instant, per design — no travel animation beyond a quick transition/sound cue).

### Exit Door System

**Decision:** The exit door is its own tappable node (same shape as a tunnel: tap → signal), placed inside whichever room is the level's exit room — reaching that room via tunnel does **not** auto-complete the level. The player must tap the door itself.

This is deliberate groundwork for a planned **Keys / Locked Exit Door** mechanic: a locked door can reject a tap (e.g. "needs a key") without needing to special-case *entering the room*, since the room swap and the completion trigger are two separate, independent events. Not building the lock/key system yet — just keeping the door as a distinct interactive node so that feature slots in later without restructuring.

### Move Counter System

**Decision:** Only entering a tunnel (moving to a different room) consumes a move. Opening the map overlay, inspecting the current room, etc. are free.

### Save System

### Map Overlay System

A HUD button (always available, not gated behind a power-up) opens a semi-transparent full-screen overlay showing rooms the player has physically visited, tap to dismiss. Free to open — does not consume a move.

The **Map Fragment** power-up spends 1 charge on use: it snapshots the tunnel connections for rooms already visited at that moment and permanently merges that data into the player's map knowledge for the rest of the attempt (does not retroactively update with rooms explored afterward). Using it with zero rooms visited wastes it — show a confirmation prompt ("No tunnels discovered yet — use anyway?") before allowing the use. See [PowerUps.md](PowerUps.md).

### Power-Up Economy System

**Decision:** Power-up stock is global and persists across levels — it is not reset by `start_level()`. Each of the three power-up types has its own stock (0-3) and its own last-refill timestamp, both saved to disk.

* **Refill:** on load, and whenever charges are read/spent, compute elapsed real time since the last-refill timestamp and add `elapsed / 10min` whole charges (capped at 3), advancing the timestamp by the amount consumed. This makes refilling correct even while the app is closed, without needing a running timer.
* **Attempt-scoped spend:** the current level attempt tracks its own deltas (which power-ups were spent this attempt, and how many). On level completion, deltas are discarded (the spend is permanent). On failure (out of moves) or on quitting/restarting the level, deltas are added back to the persistent stock.
* This replaces the current `GameState._charges` model (reset from `LevelData.starting_power_ups` in `start_level()`), which was built for the single-use-per-level tutorial design. `LevelData.starting_power_ups` remains useful only for the tutorial levels' forced first-time grant if a new player has 0 stock of that type; everywhere else, stock comes from the persistent economy.
* Rewarded-ad instant refill (future) is just "set stock to 3 and reset the refill timestamp to now" — no separate code path needed.

### Room Sizing

**Decision:** Rooms are built on a consistent grid unit (e.g. 128px tiles) against a fixed reference resolution (e.g. 1080×1920, portrait). A `Camera2D` fits each room's full grid extent to the screen — no scrolling or panning. Room dimensions (in grid units) can vary per level/room to control pacing, but the camera always frames the whole room at once so the layout stays glanceable.

## Data Structures

Since all 20 levels are handcrafted (no procedural generation), level data is authored as Godot custom `Resource` types (`.tres`) rather than JSON — editor-inspectable, typed, and diff-friendly enough for handcrafting.

* **`LevelData` (Resource):** level id, move limit (or unlimited, for levels 1-4), star thresholds, ordered list of `RoomData`.
* **`RoomData` (Resource):** room id, scene reference. No separate "exit flag" — whether a room is the exit is determined by whether an Exit Door node exists in its scene, not a resource field that could drift out of sync with the room's actual content.

The room/level controller reads a level's `LevelData` on load and never needs to hardcode room-to-room connections in script — everything comes from the resource, so building a new level is authoring data, not writing code.

## Prototype Scope

First playable prototype, per [DevLog 001](DevLog/001-Project-Kickoff.md):

* One room
* Two colored tunnels
* One exit
* Basic player movement
* No UI or power-ups yet

## Open Technical Questions

Resolved during kickoff follow-up (see decisions above):

* ~~Should movement be tile-based or tap-to-move?~~ → Tap-to-move.
* ~~How should moves be consumed?~~ → Only entering a tunnel costs a move.
* ~~What is the ideal room size?~~ → Fixed reference resolution, camera-fit-to-room, grid-based, varies per room.
* ~~How should the map be visualized?~~ → Always-available HUD button, transparent overlay.
* How many rooms should each level contain? → Decided per-level during level design/playtesting, balanced against star rating (not a fixed formula).
