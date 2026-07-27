# Level Design

All 20 handcrafted levels.

## Levels 1-4 (Tutorial)

Each level introduces exactly one new mechanic, unlimited moves, no pressure. See [GDD.md](GDD.md) and [PowerUps.md](PowerUps.md).

* **Level 1** — Room-to-room movement via tunnels, find the exit. No power-ups yet.
* **Level 2** — Compass tutorial.
* **Level 3** — Map Fragment tutorial.
* **Level 4** — Warp Scroll tutorial.

## Levels 5-9

## Levels 10-14

## Levels 15-20

## Level Template

| # | Name | Rooms | Tunnel Colors | Move Limit | Notes |
|---|------|-------|----------------|------------|-------|
| 1 | First Steps | 2 (Start, Exit) | 1 (Red) | Unlimited | Movement tutorial. Tunnel and exit door are each force-highlighted (pulsing + input-locked) on first appearance to teach tap-to-move. No power-ups. |
| 2 | Compass Point | 2 (Start, Exit) | 1 (Red) | Unlimited | Compass tutorial. Start Room locks all taps until Compass is pressed, then locks again until the (now-revealed) tunnel is tapped — can't be cancelled or skipped mid-sequence. |
| 3 | The Library | 3 (Start, Library, Exit) | 2 (Blue, Green) | Unlimited | Map Fragment tutorial. Start Room is freely tappable (no forced power-up). Library locks until Fragment is used, then locks again until Map is opened and dismissed, then unlocks the tunnel. Introduces the Map overlay (always available from here on) and the exit-room tip about using it. |
| 4 | Wrong Turn | 3 (Start, Dead End, Exit) | 2 (Purple, Orange) | Unlimited | Warp Scroll tutorial. Start Room has two tunnels; only the "wrong" one (Purple) is tappable at first, leading to a true dead end with zero tunnels/doors — Warp Scroll is the only way out. Warping back to Start Room re-locks it to the correct tunnel (Orange) instead. First level to revisit a room mid-attempt with a different forced target each time. |
