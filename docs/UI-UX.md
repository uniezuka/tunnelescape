# UI / UX

## Screens

### Map Overlay

Opened via a HUD button, always available (not gated behind a power-up). Semi-transparent, full-screen, tap anywhere to dismiss. Non-blocking — does not pause the move counter or cost a move.

Shows rooms the player has physically visited as nodes. If Map Fragment has been used, also draws the tunnel connections snapshotted at the moment of use (permanent for the rest of the attempt, does not update afterward).

### Map Fragment Confirmation Prompt

If the player tries to use Map Fragment with zero rooms visited, show a confirmation dialog ("No tunnels discovered yet — use anyway?") before allowing the use, since it would otherwise be wasted.

## HUD Layout

Bottom bar: Map, Compass, Map Fragment, Warp Scroll.

## Navigation Flow

## Accessibility Notes
