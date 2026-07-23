# Power-Ups

## Compass

Reveal the destination of one selected tunnel. Single-use.

## Map Fragment

The map overlay itself (HUD button, semi-transparent, tap to dismiss) is always available and shows rooms the player has physically visited.

Map Fragment is single-use. On use, it snapshots which tunnel leads to which room, for rooms already visited at that moment — that connection data is then permanently added to the player's map knowledge for the rest of the attempt (it does not disappear when the overlay is closed, and it does not keep updating with rooms explored afterward).

Does not reveal unexplored rooms or their connections. Using it with no rooms visited yet wastes it (nothing to snapshot) — the game shows a confirmation prompt ("No tunnels discovered yet — use anyway?") before letting the player burn it in that state.

## Warp Scroll

Instantly teleport to any previously visited room. Consumes no moves. Single-use.

## Balancing Notes
