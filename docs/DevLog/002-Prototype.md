# Development Log

## Day 2 — First Prototype

**Date:** July 26, 2026

---

## Objective

Create the actual Godot project and build the first playable prototype: one room, two colored portals, one exit, basic player movement, no UI or power-ups — per [DevLog 001](001-Project-Kickoff.md)'s next goal.

---

## Accomplishments

* Set up `godot/` following the folder layout in [Architecture.md](../Architecture.md) (`scenes/`, `scripts/`, `resources/`, `assets/`).
* Built `room_01.tscn`: one room containing a player token, a red portal, a blue portal, and a green exit.
* Implemented tap-to-move: tapping a portal or the exit glides the player token to it and reports what would happen (which room the portal leads to, or level-complete for the exit) — the first hands-on implementation of the tap-to-move decision from [TDD.md](../TDD.md).
* Kept portals/exit decoupled from the level-flow controller via signals (`portal_entered`, `exit_reached`), per the signal-based communication pattern in Architecture.md.
* Verified the project headlessly (`godot --headless --import`, multi-frame run) after every change, catching several script errors before manual testing.

---

## Technical Decisions & Fixes

* **Desktop window size:** Added `window_width_override`/`window_height_override` (540×960) so the portrait design resolution (1080×1920) fits on a normal monitor during editor testing. Confirmed this only affects desktop/editor play — Android exports always run fullscreen at native device resolution regardless of this setting.
* **Control nodes don't belong in the world hierarchy:** Originally used `ColorRect` for portal/player/exit visuals. Replaced with `Polygon2D` — `ColorRect` is a UI/`Control` node, and mixing `Control` into a `Node2D`/`Area2D` tree caused interaction issues with input handling.
* **Area2D click/tap detection didn't fire:** Spent most of the session on this. Every documented precondition for `Area2D.input_event` was verified correct (`input_pickable`, `monitoring`, `Viewport.physics_object_picking` all `true`; click position confirmed well inside the collision shape's bounds) via headless diagnostics, yet the signal never fired in-editor. Root cause unidentified — flagging for follow-up in case it resurfaces. Worked around it by having `main.gd` do direct point-in-box hit-testing against each portal/exit's bounds using `get_global_mouse_position()` on every click/tap, then calling the node's own `trigger()` method (which still emits the decoupled signal). This is deterministic and now verified working end-to-end.

---

## Open Questions

* Why did `Area2D`/`Viewport` physics-object-picking never fire despite all documented conditions being met? Not blocking (worked around with manual hit-testing), but worth revisiting if a future system wants to rely on Godot's built-in click picking.

---

## Next Goal

Extend past the single hardcoded room: build a second real room scene and make a portal actually swap the active room (rather than just logging the destination), which is the first step toward the `LevelLoader` / `LevelData` resource-driven system described in Architecture.md and TDD.md.
