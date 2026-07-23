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

* Should movement be tile-based or tap-to-move?
* How should moves be consumed?
* What is the ideal room size?
* How should the map be visualized?
* How many rooms should each level contain?

---

## Next Goal

Create the Godot project and become familiar with the engine by building a minimal prototype with:

* One room
* Two colored tunnels
* One exit
* Basic player movement

No UI or power-ups yet.
