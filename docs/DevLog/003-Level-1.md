# Development Log

## Day 3 — Tutorial Flow & Level 1

**Date:** July 26, 2026

---

## Objective

Redefine the tutorial flow, then build Level 1 as real, data-driven playable content — replacing the throwaway prototype room from [DevLog 002](002-Prototype.md).

---

## Accomplishments

* **Tutorial flow finalized:** Levels 1–4 are now tutorials, each introducing exactly one mechanic (movement/exit → Compass → Map Fragment → Warp Scroll). Updated GDD.md, LevelDesign.md, PowerUps.md, and TDD.md accordingly, and shifted the later difficulty bands (5–9, 10–14) to keep the 20-level total consistent.
* **Built the real `LevelData`/`RoomData`/`LevelLoader` pipeline** described in Architecture.md: `LevelData` and `RoomData` are Godot custom `Resource` types (`scripts/data/`), `LevelLoader` is an autoload that instantiates a level's starting room and swaps rooms on request, emitting a `room_loaded` signal so `main.gd` can rewire itself to whatever room is currently active.
* **Built Level 1** ("First Steps"): a Start Room (one tunnel) and an Exit Room, connected by a single red tunnel. Authored as `level_01.tres` rather than hardcoded scene references.
* **Tutorial "force click" pattern:** a `Tappable` base class (shared by `Tunnel` and the new `ExitDoor`) supports a pulsing highlight plus a level-controller-side input lock that ignores taps anywhere except the highlighted target. Both the Start Room's tunnel and the Exit Room's door use this on first appearance.
* Added a one-line tutorial caption per room (a minimal, room-specific exception to the "no UI yet" prototype constraint — not the general HUD system).

---

## Design Change: Exit Door Is Tappable, Not Automatic

Originally, reaching the room flagged `is_exit` immediately completed the level. Reconsidered this mid-session: future levels are planned to include **Keys** and a **Locked Exit Door** (see [Ideas.md](../Ideas.md)), and a locked door needs to reject a *tap* — rejecting *room entry* would be awkward to model. So:

* The Exit Door is now its own tappable node (`ExitDoor`, extends `Tappable`) placed inside the exit room. Reaching the room via tunnel no longer auto-completes the level; the player must tap the door.
* Removed `RoomData.is_exit` entirely — it had become a flag with no real reason to exist independent of the door node itself, and could silently drift out of sync with a room's actual content. Whether a room is "the exit room" is now just a fact about what's inside its scene, not separate metadata to keep in sync.
* Updated TDD.md (new "Exit Door System" section) and GDD.md's Exit Door section to match, and logged the Keys/Locked Door idea in Ideas.md as explicitly out of scope for now.

---

## Bug Found & Fixed

Headless testing of the room-swap logic caught a real bug: `queue_free()` on the old room defers actual removal by a frame, so immediately after swapping, the old room's tappables were still technically present in the `"tappables"` group — causing a duplicate signal connection on the new room's (identically-named) tunnel group lookup. Fixed by scoping all tappable lookups to `_current_room.is_ancestor_of(node)` instead of querying the group tree-wide.

---

## Next Goal

Design and build Level 2: the Compass tutorial. Needs a first real power-up interaction (tap the Compass, then tap a tunnel to reveal its destination) using the same tutorial force-highlight pattern established in Level 1.
