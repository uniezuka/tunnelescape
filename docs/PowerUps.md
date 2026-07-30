# Power-Ups

## Economy

Power-ups are not handed out per level — each of the three is a **stock the player owns across the whole game**:

* **Max stock: 3 per power-up type.** Compass, Map Fragment, and Warp Scroll each keep their own stock and their own refill timer. They do not share a pool.
* Using a power-up spends **1 charge** from its stock.
* Charges **refill over real time**: about 1 charge every 10 minutes per type, so an empty stock is back to full in about 30 minutes.
* **Refund on fail:** charges only leave the stock for good when the level is *completed*. Running out of moves, or quitting/restarting mid-attempt, refunds every charge spent during that attempt.
* **Rewarded ads** will let the player instantly refill a power-up's stock to full. Planned for a future update, not Version 1.0.
* New players start with full stock (3 of each). The tutorial (Levels 2-4) forces the use of one power-up per level to demonstrate it, but this doesn't spend from the real stock — real spending starts at Level 5, the first non-tutorial level, so every player reaches it with the full 3 of each.

## Compass

Reveal the destination of one selected portal. Spends 1 charge.

First introduced: Level 2 (tutorial).

## Map Fragment

The map overlay itself (HUD button, semi-transparent, tap to dismiss) is always available and shows rooms the player has physically visited.

Map Fragment spends 1 charge on use. On use, it snapshots which portal leads to which room, for rooms already visited at that moment — that connection data is then permanently added to the player's map knowledge for the rest of the attempt (it does not disappear when the overlay is closed, and it does not keep updating with rooms explored afterward).

Does not reveal unexplored rooms or their connections. Using it with no rooms visited yet wastes it (nothing to snapshot) — the game shows a confirmation prompt ("No portals discovered yet — use anyway?") before letting the player burn it in that state.

First introduced: Level 3 (tutorial).

## Warp Scroll

Instantly teleport to any previously visited room. Consumes no moves. Spends 1 charge.

First introduced: Level 4 (tutorial).

## Balancing Notes

* Level design must never require a power-up to solve a level — they exist to cut down on frustration and reward exploration, not to gate completion. The only exception is the scripted first-time tutorial use in Levels 2-4.
* **Level 5 onward: no room is ever a true dead end.** Every room must have at least one real portal out. Level 4's Dead End room (zero portals, Warp Scroll required to escape) was a deliberate one-time tutorial exception and must not be repeated. This guarantees a player with 0 charges of everything can still always finish a level — they just may have to take the long way.
* Because stock is shared across the whole game (not reset per level), a level should be solvable with 0 of any power-up in stock — a player who burned all their charges a few levels back and hasn't waited for a refill must still be able to finish.
* When balancing move limits for a level, assume the player has 2-3 of each power-up available, not fewer — the refund-on-fail rule means stock rarely stays depleted for long once a player is engaged with a level. Level 5 specifically can assume the full 3 of each, since that's the first level where the real stock is ever spent.
