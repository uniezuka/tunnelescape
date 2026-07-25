# Ideas

## Keys / Locked Exit Door

Future mechanic (not in Version 1.0 scope): some levels could place a **Key** item in a room, and the exit door in those levels is locked until the player has picked it up. Tapping a locked door without the key rejects the action (e.g. a brief "needs a key" message) instead of completing the level.

Feasible without restructuring because the exit door is already implemented as its own tappable node, independent from the room-swap/teleport flow — see [TDD.md](TDD.md)'s Exit Door System and [GDD.md](GDD.md)'s Exit Door section.
