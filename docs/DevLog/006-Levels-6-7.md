# Development Log

## Day 6 — Design Tier Re-Split and Levels 6-7

**Date:** July 31, 2026

---

## Objective

Originally scoped as "finish the Levels 5-9 tier." Re-split the design tiers before doing any more level work: **5-7, 8-10, 11-14, 15-18, 19-20** instead of the old **5-9, 10-14, 15-20**. Levels 5-7 are deliberately the *same* difficulty as Level 5 — same room count, same portal count, same move limit, same star thresholds — just a different portal graph each time. The real difficulty step up now starts at Level 8, which is also where the Library theme hands off to a new one (was previously slated for Level 6).

---

## Re-Tiering + Levels 6-7 Design

* **`LevelDesign.md`** updated: tier headers and the Star Threshold Methodology note now read 5-7 / 8-10 / 11-14 / 15-18 / 19-20. The "new theme" hand-off moved from Level 6 to Level 8 to match — Levels 1-7 are now all Library-themed.
* **Level 6 ("The Long Way Round")** and **Level 7 ("Crossed Paths")** designed in LevelDesign.md's Level Template table, matching Level 5's exact numbers (5 rooms, 3 colors, 8 portals, `move_limit = 12`, 2-move optimal, 3-move longer-valid, same star thresholds) but each with its own portal graph shape — Level 6 is a short-branch/long-branch split, Level 7 crosses both branches into a shared middle room. Design-only so far: no `.tres`/`.tscn` files yet, same as how Level 5's design (Day 4) preceded its build (Day 5).
* Added **`docs/MovesCheatSheet.md`** — fastest/longer routes and star thresholds for Levels 1-7 in one place, so a route doesn't need to be re-derived from LevelDesign.md's prose every time.

---

## Levels 6-7 Built

Built both levels in Godot exactly per the design above, following Level 5's file pattern — same room/portal scene structure, same Portal/ExitDoor/Player scenes reused, same Library `RoomTheme`, same `star_3_threshold = 4` / `star_2_threshold = 8` / `move_limit = 12`.

* `room_06_start.tscn`, `room_06_librarian_office.tscn`, `room_06_astronomer_study.tscn`, `room_06_card_catalog.tscn`, `room_06_exit.tscn` — `level_06.tres` ties them together.
* `room_07_start.tscn`, `room_07_reading_room.tscn`, `room_07_crystal_repository.tscn`, `room_07_reading_nook.tscn`, `room_07_exit.tscn` — `level_07.tres` ties them together.
* Wired `level_05.tres.next_level_path` → `level_06.tres`, and `level_06.tres.next_level_path` → `level_07.tres`. `level_07.tres.next_level_path` is left blank, same as Level 5 was until Level 6 existed.
* Cross-checked every `destination_room_id` in both levels' room scenes against the room ids actually defined in their `.tres` files — all resolve, no dangling portals.

**Not tested in-engine.** Same caveat as Level 5's first build: reviewed by hand for consistency against the working pattern, not clicked through live yet.

---

## Next Goal

Playtest Levels 6-7 in the editor (use `docs/MovesCheatSheet.md` for the expected routes and star thresholds). Then design Levels 8-10: pick the next theme (Temple is next in ArtGuide.md's list) and the first real difficulty step up past this tier.

---
