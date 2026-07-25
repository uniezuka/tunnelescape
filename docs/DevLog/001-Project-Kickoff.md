# Development Log

## Day 1 — Project Kickoff

**Date:** July 24, 2026

---

## Objective

Start development of a new Android puzzle game and establish a clear project foundation before writing code.

---

## Accomplishments

* Chose **Godot 4** as the game engine.
* Decided to target **Android** for the initial release.
* Confirmed the monetization strategy will rely solely on advertisements.
* Created the first draft of the Game Design Document (GDD).
* Created the project README.
* Defined the MVP scope as **20 handcrafted levels**.

---

## Core Gameplay Decisions

* Players explore interconnected rooms linked by **colored teleportation tunnels**.
* The objective is to find the exit before running out of moves.
* The exit door is never locked.
* Levels 1–3 will act as tutorials with unlimited moves.
* Move limits will be introduced starting from later levels.
* Initial release will include three power-ups:

  * Compass
  * Map Fragment
  * Warp Scroll

---

## Design Philosophy

Keep the game simple.

Every new mechanic must support the core gameplay of:

**Explore → Remember → Optimize → Escape**

Avoid adding unnecessary complexity such as enemies, combat, or timers during the MVP phase.

---

## Technical Decisions

Engine:

* Godot 4

Language:

* GDScript

Editor:

* VS Code

Version Control:

* Git

Platform:

* Android

---

## Open Questions

Resolved in follow-up discussion (see [GDD.md](../GDD.md) and [TDD.md](../TDD.md) for full detail):

* ~~Should movement be tile-based or tap-to-move?~~ → Tap-to-move; no free walking inside a room.
* ~~How should moves be consumed?~~ → Only entering a tunnel (moving to a different room) costs a move.
* ~~What is the ideal room size?~~ → Fixed reference resolution, grid-based, camera fits each room to screen; size varies per room.
* ~~How should the map be visualized?~~ → Always-available HUD button opens a transparent overlay of visited rooms; Map Fragment (single-use) additionally snapshots tunnel connections permanently into that view.
* ~~How many rooms should each level contain?~~ → Decided per-level during level design/playtesting, balanced against star rating — not a fixed formula.

---

## Next Goal

Create the Godot project and become familiar with the engine by building a minimal prototype with:

* One room
* Two colored tunnels
* One exit
* Basic player movement

No UI or power-ups yet.
