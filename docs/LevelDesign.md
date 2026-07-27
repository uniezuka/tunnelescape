# Level Design

All 20 handcrafted levels.

## Levels 1-4 (Tutorial)

Each level introduces exactly one new mechanic, unlimited moves, no pressure. See [GDD.md](GDD.md) and [PowerUps.md](PowerUps.md). Levels 1-5 all share the 📚 Library [room theme](ArtGuide.md#room-themes) — the player learns the whole game inside one location before moving on to a new theme at Level 6. Start Room and Exit Room are always "The Library Entrance" and "The Grand Reading Hall" (fixed per theme, see ArtGuide.md).

* **Level 1** — Room-to-room movement via tunnels, find the exit. No power-ups yet.
* **Level 2** — Compass tutorial.
* **Level 3** — Map Fragment tutorial. Middle room: The Forgotten Archive.
* **Level 4** — Warp Scroll tutorial. Dead-end room: The Rare Books Wing.

## Levels 5-9

Move limit turns on, room count grows, and a third tunnel color appears. Rooms are no longer forced open one at a time like the tutorial — the player picks their own path, and each level has at least one branch that looks fine but is actually the long way round. Power-ups are never required to finish; they just make the exploring faster. See [Power-Up Economy](GDD.md#power-up-economy) for how much stock a player realistically has at this point (2-3 of each, if they're not letting stock sit unused).

* **Level 5** — First move-limited level. Last of the Library-themed levels, with 3 middle rooms this time (The Potion Workshop, The Scriptorium, The Ancient Records Vault) alongside the fixed Library Entrance/Grand Reading Hall. The Library Entrance (start) has two tunnels: Red goes straight toward the exit, Green leads into a small loop that costs moves before dropping the player back near the start. The point isn't to punish the "wrong" choice hard — it's to introduce, gently, that not every tunnel is progress.

## Levels 10-14

## Levels 15-20

## Level Template

| # | Name | Rooms | Tunnel Colors | Move Limit | Notes |
|---|------|-------|----------------|------------|-------|
| 1 | First Steps | 2 (The Library Entrance, The Grand Reading Hall) | 1 (Red) | Unlimited | Movement tutorial. Tunnel and exit door are each force-highlighted (pulsing + input-locked) on first appearance to teach tap-to-move. No power-ups. |
| 2 | Compass Point | 2 (The Library Entrance, The Grand Reading Hall) | 1 (Red) | Unlimited | Compass tutorial. Start Room locks all taps until Compass is pressed, then locks again until the (now-revealed) tunnel is tapped — can't be cancelled or skipped mid-sequence. |
| 3 | The Library | 3 (The Library Entrance, The Forgotten Archive, The Grand Reading Hall) | 2 (Blue, Green) | Unlimited | Map Fragment tutorial. Start Room is freely tappable (no forced power-up). The Forgotten Archive locks until Fragment is used, then locks again until Map is opened and dismissed, then unlocks the tunnel. Introduces the Map overlay (always available from here on) and the exit-room tip about using it. |
| 4 | Wrong Turn | 3 (The Library Entrance, The Rare Books Wing, The Grand Reading Hall) | 2 (Purple, Orange) | Unlimited | Warp Scroll tutorial. Start Room has two tunnels; only the "wrong" one (Purple) is tappable at first, leading to The Rare Books Wing — a true dead end with zero tunnels/doors — Warp Scroll is the only way out. Warping back to the Library Entrance re-locks it to the correct tunnel (Orange) instead. First level to revisit a room mid-attempt with a different forced target each time. |
| 5 | Going in Circles | 5 (The Library Entrance, The Potion Workshop, The Scriptorium, The Ancient Records Vault, The Grand Reading Hall) | 3 (Red, Green, Yellow) | 12 (provisional — optimal is 2, generous buffer since this is the first level with a move limit at all) | First move-limited level, first level with 3 tunnel colors, last of the Library-themed levels (see [ArtGuide.md](ArtGuide.md#room-themes)), first level where the player picks their own path (no forced power-up gates). Network: Library Entrance –Red→ Potion Workshop, Library Entrance –Green→ Scriptorium; Potion Workshop –Yellow→ Grand Reading Hall, Potion Workshop –Green→ Ancient Records Vault; Scriptorium –Red→ Ancient Records Vault, Scriptorium –Yellow→ Library Entrance (loops back); Ancient Records Vault –Red→ Grand Reading Hall, Ancient Records Vault –Green→ Library Entrance (also loops back). Fastest route (Red, Yellow) finishes in 2 moves; the Green branch from the Library Entrance is the "misleading" one — it never dead-ends completely, but both of its tunnels either loop back to the start or take the long way to the Grand Reading Hall via the Ancient Records Vault. Star thresholds (provisional, pending playtest): ⭐⭐⭐ ≤ 4, ⭐⭐ ≤ 8, ⭐ = finish within 12. |
