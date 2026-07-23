# Tunnel Escape

## Game Design Document (GDD)

**Version:** 0.1 (Draft)
**Status:** Pre-Production

---

# 1. Overview

## Working Title

**Tunnel Escape**

*(Working title. Subject to change.)*

## Genre

Puzzle / Memory / Strategy

## Platform

* Android (Primary)
* Portrait Mode
* Offline Single Player

## Target Audience

Players who enjoy short puzzle games that require observation, planning, and memory.

## Monetization

Advertisement only.

No pay-to-win mechanics.

---

# 2. Vision

Tunnel Escape is a puzzle game where players explore a network of interconnected rooms linked by colored teleportation tunnels.

Each level begins with the player in an unknown room. By exploring tunnels, remembering where they lead, and carefully managing limited moves, the player must locate the exit door before running out of moves.

The game should make players feel clever rather than lucky.

The challenge comes from learning the map—not from random chance.

---

# 3. Design Goals

### Easy to Learn

Players should understand the objective within the first minute.

### Difficult to Master

Later levels should reward memory, planning, and route optimization.

### Short Sessions

Each level should take approximately:

* 1–3 minutes
* Easy to restart
* Easy to replay

### Relaxing

No enemies.
No combat.
No timers.

Players should feel challenged, not stressed.

---

# 4. Core Gameplay Loop

1. Start the level.
2. Explore rooms using colored tunnels.
3. Memorize tunnel destinations.
4. Locate the exit room.
5. Reach the exit before running out of moves.
6. Earn a star rating.
7. Unlock the next level.

---

# 5. Core Mechanics

## Rooms

Each level is made up of multiple handcrafted rooms.

Every room contains:

* Colored tunnels
* Decorative theme
* Optional power-up
* Exit door (only one room contains the exit)

Rooms are connected only through teleportation tunnels.

---

## Colored Tunnels

Colored tunnels instantly teleport the player to another room.

Example colors:

* 🔴 Red
* 🔵 Blue
* 🟢 Green
* 🟣 Purple

A tunnel always leads to the same destination within a level.

Players gradually learn the tunnel network through exploration.

---

## Exit Door

The exit door is never locked.

Finding the correct room is the puzzle.

Walking into the exit completes the level.

---

## Moves

Only entering a tunnel (moving to a different room) consumes one move.

Looking around the current room, opening the map overlay, and other non-travel actions are free.

Running out of moves results in a level failure.

**Tutorial levels (1–3) have unlimited moves.**

---

# 6. Difficulty Progression

## Levels 1–3

Tutorial

Objectives:

* Learn movement
* Learn tunnels
* Learn exits

Unlimited moves.

No pressure.

---

## Levels 4–8

Introduce:

* Move limit
* More rooms
* Three tunnel colors

---

## Levels 9–14

Introduce:

* Larger maps
* More misleading routes
* Route optimization

---

## Levels 15–20

Introduce:

* Large handcrafted layouts
* Tight move limits
* Multiple viable routes
* Greater emphasis on planning

---

# 7. Power-Ups

Only three power-ups will exist in Version 1.0.

---

## Compass

Reveal the destination of one selected tunnel.

Example:

Player taps a tunnel.

Compass displays:

"Leads to Library."

Single-use.

---

## Map Fragment

A map overlay (opened via a HUD button) is always available and shows the rooms the player has physically visited.

Map Fragment is single-use. On use, it snapshots which tunnel leads to which room for rooms already visited at that moment, and that connection data becomes a permanent part of the player's map knowledge for the rest of the attempt.

Using it before exploring anything wastes it — a confirmation prompt warns the player first.

It does **not** reveal unexplored areas or connections to rooms the player hasn't been to yet, and it does not keep revealing new connections discovered after the moment it's used.

Purpose:

Reduce frustration while still rewarding exploration — the base overlay tracks *where you've been*, Map Fragment is a deliberate, timed decision about *when to learn how it connects*.

---

## Warp Scroll

Instantly teleport to any previously visited room.

Consumes no moves.

Single-use.

Useful for recovering from inefficient exploration.

---

# 8. Scoring

Every level awards up to three stars.

Example:

| Result    | Rating |
| --------- | ------ |
| Excellent | ⭐⭐⭐    |
| Good      | ⭐⭐     |
| Completed | ⭐      |

Exact thresholds will be balanced during playtesting.

---

# 9. Level Progression

Version 1.0 contains:

* 20 handcrafted levels

Levels gradually introduce:

* More rooms
* More tunnel colors
* More complex layouts
* Tighter move limits

No procedural generation in Version 1.0.

---

# 10. Art Direction

Style:

Minimalist

Readable

Bright

Clean

Each room should be visually unique so players can easily recognize where they are.

Example room themes:

* Stone Dungeon
* Library
* Garden
* Laboratory
* Temple
* Ice Cave
* Observatory
* Castle

---

# 11. Audio

Relaxing background music.

Simple sound effects:

* Walking
* Entering tunnel
* Discovering exit
* Level complete
* Error / no moves

---

# 12. User Interface

Top Bar

* Current Level
* Moves Remaining

Top Right

* Pause
* Settings

Bottom

* Map (always available — shows visited rooms; enhanced by Map Fragment)
* Compass
* Map Fragment
* Warp Scroll

Center

Current room and interactive objects.

---

# 13. Saving

Automatically save:

* Highest unlocked level
* Star ratings
* Best move count
* Available power-ups

---

# 14. Advertisement Strategy

### Banner Ads

Menus only.

Never during gameplay.

---

### Interstitial Ads

Display after every few completed levels.

Never immediately after a failed attempt.

---

### Rewarded Ads

Optional.

Rewards may include:

* Extra Moves
* Compass
* Map Fragment
* Warp Scroll

Players are never forced to watch rewarded ads.

---

# 15. MVP Scope

Version 1.0 will include:

* 20 handcrafted levels
* Colored teleport tunnels
* Move system
* Exit doors
* Three power-ups
* Star rating system
* Save progress
* Sound effects
* Background music
* Google AdMob integration
* Offline gameplay

---

# 16. Future Features (Out of Scope)

These ideas are intentionally excluded from Version 1.0.

Potential future updates:

* Daily Puzzle
* Endless Mode
* Procedurally Generated Levels
* New Tunnel Types
* Additional Power-Ups
* Achievements
* Cosmetic Themes
* Leaderboards
* Cloud Save
* iOS Release

---

# 17. Open Questions

Resolved (see [TDD.md](TDD.md) for technical detail):

* ~~How should moves be consumed?~~ → Only entering a tunnel costs a move.
* ~~Should the player freely walk inside each room, or simply tap tunnels and the exit?~~ → Tap-to-move only; no free walking.
* ~~How many rooms create the ideal difficulty?~~ → Decided per-level during level design/playtesting.

Still open, to be finalized during prototyping:

* Should rooms have fixed layouts or slight variations?
* What are the exact thresholds for ⭐⭐⭐, ⭐⭐, and ⭐ scoring?
* How many power-ups should players start with, and how are additional ones earned?

---

# 18. Development Roadmap

## Phase 1

* Learn Godot
* Build prototype
* Basic movement
* Teleportation

## Phase 2

* Move system
* Exit system
* Save system

## Phase 3

* Power-ups
* UI
* Sound
* Animations

## Phase 4

* Design and implement 20 handcrafted levels

## Phase 5

* Polish
* Ads
* Google Play release

---

# Design Philosophy

Tunnel Escape is designed around a single principle:

**Simple rules create satisfying puzzles.**

Rather than overwhelming players with complex mechanics, the game challenges them to explore, remember, and optimize. Every level should provide a small "aha!" moment where the player realizes a more efficient route or finally understands how the teleportation network fits together.

The goal is not to create a difficult game—it is to create a game that makes players feel smart.
