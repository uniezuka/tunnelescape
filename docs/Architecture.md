# Godot Project Architecture

## Folder Structure

```text
godot/
├── project.godot
├── scenes/
│   ├── main/          Main.tscn — root scene, holds current room + HUD
│   ├── rooms/          One .tscn per handcrafted room
│   ├── ui/             HUD, map overlay, pause/settings, level select
│   └── portal/         Portal.tscn — reusable tappable portal node
├── scripts/
│   ├── autoload/       GameState.gd, SaveManager.gd, LevelLoader.gd
│   ├── systems/        movement, portal/teleport, move counter
│   └── data/           LevelData.gd, RoomData.gd (Resource scripts)
├── resources/
│   └── levels/         level_01.tres … level_20.tres (handcrafted LevelData)
└── assets/              Imported, engine-ready assets actually referenced by scenes
```

**Note:** The top-level `TunnelEscape/assets/` folder (sibling of `godot/`) should be treated as a *source* staging area — raw art files (e.g. Aseprite/PSD), unmixed audio, etc. Godot can only import/reference files that live inside the project directory (`res://`), so anything actually used at runtime needs to be copied/exported into `godot/assets/`. Flagging this now so it's a deliberate pipeline decision rather than a surprise later.

## Scene Structure

* `Main.tscn` — root scene (autoload-independent), instances the current room scene as a child and hosts the HUD overlay.
* Each room is its own scene (`scenes/rooms/room_XX.tscn`), containing its portals, exit (if any), decorative theme, and optional power-up pickup.
* `Portal.tscn` is a reusable scene/prefab instanced inside each room, configured per-instance with its color and destination room id.

## Autoloads / Singletons

* **`GameState`** — current level, current room, moves remaining, active power-up inventory.
* **`SaveManager`** — persists highest unlocked level, star ratings, best move counts, power-up counts.
* **`LevelLoader`** — loads a `LevelData` resource and swaps the active room scene.

## Naming Conventions

* Files/scripts: `snake_case.gd`, `snake_case.tscn`.
* Node names in the scene tree: `PascalCase`.
* Signals: `snake_case`, past-tense for events (`portal_entered`, `level_completed`).

## Signals & Communication Patterns

Prefer signals over direct references between systems (e.g. a `Portal` node emits `portal_entered(destination_room_id)` rather than calling into `LevelLoader` directly), so rooms/portals stay decoupled from the level-flow controller and can be reused across all 20 levels without per-level wiring.
