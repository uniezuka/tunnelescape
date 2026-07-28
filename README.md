# Portal Escape

*A memory-based puzzle game about exploring mysterious teleportation portals.*

---

## Overview

Portal Escape is a 2D puzzle game for Android where players navigate a network of interconnected rooms linked by colored teleportation portals.

The objective is simple:

> **Find the exit before running out of moves.**

As players progress, they must memorize portal destinations, optimize their routes, and use limited power-ups to solve increasingly challenging handcrafted levels.

---

## Vision

Portal Escape is designed around one core idea:

> **Simple rules create satisfying puzzles.**

The game avoids unnecessary complexity. There are no enemies, combat, timers, or random events.

Instead, the challenge comes from observation, memory, and planning.

Players should finish a level thinking:

> *"I know a better route now."*

---

## Core Features

* 20 handcrafted puzzle levels
* Colored teleportation portals
* Move-based gameplay
* Three collectible power-ups
* Star rating system
* Offline gameplay
* Rewarded advertisements
* Clean and minimalist visual style

---

## Gameplay

Each level consists of multiple rooms connected by colored portals.

Players begin with no knowledge of the map.

To complete a level:

1. Explore rooms.
2. Discover where portals lead.
3. Remember the layout.
4. Find the exit.
5. Reach it before running out of moves.

---

## Power-Ups

### 🧭 Compass

Reveal where one selected portal leads.

---

### 🗺️ Map Fragment

Single-use. Snapshots which portal leads to which room, for rooms already visited at that moment, and permanently adds that to the player's map knowledge for the rest of the attempt. A separate, always-available map button shows rooms visited regardless of this power-up.

---

### ✨ Warp Scroll

Instantly teleport to any previously visited room without consuming moves.

---

## Technology Stack

| Component       | Technology               |
| --------------- | ------------------------ |
| Engine          | Godot 4                  |
| Language        | GDScript                 |
| IDE             | VS Code                  |
| Version Control | Git                      |
| Platform        | Android                  |
| Ads             | Google AdMob *(planned)* |

---

## Project Structure

```text
TunnelEscape/
│
├── docs/
│   ├── GDD.md
│   ├── TDD.md
│   ├── Architecture.md
│   ├── LevelDesign.md
│   ├── PowerUps.md
│   ├── UI-UX.md
│   ├── ArtGuide.md
│   ├── Audio.md
│   ├── Ideas.md
│   └── DevLog/
│       ├── 001-Project-Kickoff.md
│       ├── 002-Prototype.md
│       ├── 003-Teleport-System.md
│       ├── 004-Move-System.md
│       └── 005-Level1.md
│
├── godot/
│
├── assets/
│
└── README.md
```

---

## Development Roadmap

### Phase 1

* Learn Godot fundamentals
* Build a playable prototype

### Phase 2

* Implement core gameplay
* Teleportation system
* Move counter
* Exit system

### Phase 3

* UI
* Save system
* Power-ups
* Sound effects

### Phase 4

* Design and build 20 handcrafted levels

### Phase 5

* Polish
* Advertisement integration
* Google Play release

---

## Current Status

**Prototyping**

Completed:

* Learned Godot fundamentals and built the first playable prototype
* Core teleportation and exit-door systems implemented, driven by data (`LevelData`/`RoomData` resources + a `LevelLoader` autoload) rather than hardcoded per-room logic
* Tutorial flow finalized: Levels 1-4, each introducing exactly one new mechanic

Current focus:

* Building Level 1 (movement + exit tutorial) as real playable content
* Designing Levels 2-4 (Compass, Map Fragment, Warp Scroll tutorials)

---

## Long-Term Goals

After Version 1.0:

* Additional level packs
* Daily challenges
* Endless mode
* New room themes
* New portal mechanics
* Achievement system
* iOS release

---

## Design Philosophy

Portal Escape is intended to be a game that anyone can understand within minutes but continue improving at through smarter routing and better memory.

Rather than overwhelming players with mechanics, every new level should introduce interesting decisions while remaining approachable.

The ultimate goal is to create a polished puzzle experience that players enjoy returning to, making it well suited for short mobile gaming sessions.

---

## License

Copyright © 2026.

All rights reserved unless otherwise specified.
