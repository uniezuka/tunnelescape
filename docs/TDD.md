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

Since movement is tap-to-move (no free walking, no physical collision), a tunnel is a tappable node in the room scene (e.g. an `Area2D` or `TextureButton` with an `input_event`/`pressed` signal), not a trigger the player walks into.

Flow on tap:

1. Tunnel node emits a signal (e.g. `tunnel_entered(destination_room_id)`).
2. Room/level controller looks up the destination room from the level's data (see Data Structures).
3. Move counter decrements by 1.
4. Current room scene is swapped for the destination room scene (instant, per design — no travel animation beyond a quick transition/sound cue).
5. If the destination room is the exit room, level-complete flow triggers instead of a normal room swap.

### Move Counter System

**Decision:** Only entering a tunnel (moving to a different room) consumes a move. Opening the map overlay, inspecting the current room, etc. are free.

### Save System

### Map Overlay System

A HUD button (always available, not gated behind a power-up) opens a semi-transparent full-screen overlay showing rooms the player has physically visited, tap to dismiss. Free to open — does not consume a move.

The **Map Fragment** power-up is single-use: on use, it snapshots the tunnel connections for rooms already visited at that moment and permanently merges that data into the player's map knowledge for the rest of the attempt (does not retroactively update with rooms explored afterward). Using it with zero rooms visited wastes it — show a confirmation prompt ("No tunnels discovered yet — use anyway?") before allowing the use. See [PowerUps.md](PowerUps.md).

### Room Sizing

**Decision:** Rooms are built on a consistent grid unit (e.g. 128px tiles) against a fixed reference resolution (e.g. 1080×1920, portrait). A `Camera2D` fits each room's full grid extent to the screen — no scrolling or panning. Room dimensions (in grid units) can vary per level/room to control pacing, but the camera always frames the whole room at once so the layout stays glanceable.

## Data Structures

Since all 20 levels are handcrafted (no procedural generation), level data is authored as Godot custom `Resource` types (`.tres`) rather than JSON — editor-inspectable, typed, and diff-friendly enough for handcrafting.

* **`LevelData` (Resource):** level id, move limit (or unlimited, for levels 1-3), star thresholds, ordered list of `RoomData`.
* **`RoomData` (Resource):** room id, theme/visual identifier, exit flag, optional power-up placement, `Dictionary[tunnel_color] -> destination_room_id`.

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
