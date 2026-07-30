extends Node2D

@onready var _room_container: Node2D = $RoomContainer
@onready var _hud: HUD = $HUD

@export var starting_level_path: String = "res://resources/levels/level_01.tres"

var _current_room: Node2D
var _player: Node2D
var _tutorial_lock_target: Node2D
var _tutorial_awaiting_power_up: String = ""
var _tutorial_awaiting_map: bool = false
var _tutorial_forcing_compass_reveal: bool = false
var _level_complete: bool = false
var _level_failed: bool = false
var _pending_next_level_path: String = ""
var _current_level_path: String = ""

func _ready() -> void:
	GameState.charges_changed.connect(_on_powerup_charges_changed)
	_hud.compass_pressed.connect(_on_compass_pressed)
	_hud.continue_pressed.connect(_on_continue_pressed)
	_hud.map_pressed.connect(_on_map_pressed)
	_hud.fragment_pressed.connect(_on_fragment_pressed)
	_hud.fragment_use_anyway_pressed.connect(_on_fragment_use_anyway_pressed)
	_hud.fragment_cancel_pressed.connect(_on_fragment_cancel_pressed)
	_hud.warp_pressed.connect(_on_warp_pressed)
	_hud.warp_room_selected.connect(_on_warp_room_selected)
	_hud.warp_cancel_pressed.connect(_on_warp_cancel_pressed)
	_hud.retry_pressed.connect(_on_retry_pressed)
	LevelLoader.room_loaded.connect(_on_room_loaded)
	_start_level(starting_level_path)

func _start_level(level_path: String) -> void:
	_current_level_path = level_path
	_level_failed = false
	_hud.hide_fail_overlay()
	var level: LevelData = load(level_path)
	_hud.set_level_label(level.level_number)
	GameState.start_level(level)
	LevelLoader.start_level(level, _room_container)

func _on_room_loaded(room_node: Node2D, room_data: RoomData) -> void:
	_current_room = room_node
	_level_complete = false
	_pending_next_level_path = ""
	_hud.set_continue_visible(false)
	_hud.hide_stars()
	_hud.set_utility_buttons_disabled(false)
	_tutorial_lock_target = null
	_player = room_node.get_node("Player")

	var is_revisit: bool = GameState.get_visited_rooms().has(room_data.room_id)
	GameState.mark_visited(room_data.room_id)

	var room_label: Label = room_node.get_node_or_null("RoomLabel")
	if room_label:
		room_label.text = room_data.get_display_name(LevelLoader.current_level)

	var caption: Label = room_node.get_node_or_null("Caption")
	if is_revisit and room_data.revisit_caption != "" and caption:
		caption.text = room_data.revisit_caption

	for tappable in _get_room_tappables():
		if tappable is Portal:
			tappable.portal_entered.connect(_on_portal_entered.bind(tappable))
		elif tappable is ExitDoor:
			tappable.door_opened.connect(_on_door_opened.bind(tappable))
		var wants_highlight: bool = tappable.tutorial_highlight_on_revisit if is_revisit else tappable.tutorial_highlight
		if wants_highlight:
			_tutorial_lock_target = tappable

	if _tutorial_lock_target:
		_tutorial_lock_target.set_highlighted(true)

	_tutorial_awaiting_power_up = ""
	_tutorial_awaiting_map = false
	_tutorial_forcing_compass_reveal = false
	_hud.set_compass_highlighted(false)
	_hud.set_fragment_highlighted(false)
	_hud.set_map_highlighted(false)
	_hud.set_warp_highlighted(false)

	var required: String = room_data.requires_power_up
	if required != "" and GameState.get_charges(required) > 0:
		_tutorial_awaiting_power_up = required
		if required == "compass":
			_hud.set_compass_highlighted(true)
		elif required == "map_fragment":
			_hud.set_fragment_highlighted(true)
		elif required == "warp_scroll":
			_hud.set_warp_highlighted(true)

	_hud.set_compass_visible(GameState.get_charges("compass") > 0)
	_hud.set_fragment_visible(GameState.get_charges("map_fragment") > 0)
	_hud.set_warp_visible(GameState.get_charges("warp_scroll") > 0)
	_hud.set_map_visible(GameState.map_unlocked)

	_hud.set_moves_label(GameState.moves_remaining, GameState.has_unlimited_moves())
	if GameState.is_out_of_moves() and room_data.room_role != "exit":
		_level_failed = true
		_hud.show_fail_overlay()

func _get_room_tappables() -> Array:
	var tappables: Array = []
	for node in get_tree().get_nodes_in_group("tappables"):
		if _current_room.is_ancestor_of(node):
			tappables.append(node)
	return tappables

func _on_powerup_charges_changed(power_up_id: String, remaining: int) -> void:
	var has_charges: bool = remaining > 0
	if power_up_id == "compass":
		_hud.set_compass_visible(has_charges)
		if not has_charges:
			_hud.set_compass_armed(false)
	elif power_up_id == "map_fragment":
		_hud.set_fragment_visible(has_charges)
	elif power_up_id == "warp_scroll":
		_hud.set_warp_visible(has_charges)

func _on_compass_pressed() -> void:
	if GameState.get_charges("compass") <= 0:
		return
	if GameState.armed_power_up == "compass":
		if _tutorial_forcing_compass_reveal:
			return
		GameState.disarm()
		_hud.set_compass_armed(false)
		return
	GameState.arm("compass")
	_hud.set_compass_armed(true)
	if _tutorial_awaiting_power_up == "compass":
		_tutorial_awaiting_power_up = ""
		_tutorial_forcing_compass_reveal = true
		_hud.set_compass_highlighted(false)
		var caption: Label = _current_room.get_node_or_null("Caption")
		if caption:
			caption.text = "Now tap the glowing portal to reveal where it leads."

func _on_fragment_pressed() -> void:
	if GameState.get_charges("map_fragment") <= 0:
		return
	if not GameState.has_known_connections():
		_hud.show_fragment_confirm()
		return
	_use_map_fragment()

func _use_map_fragment() -> void:
	GameState.snapshot_known_connections()
	GameState.consume("map_fragment")
	_hud.set_fragment_highlighted(false)
	GameState.unlock_map()
	_hud.set_map_visible(true)
	if _tutorial_awaiting_power_up == "map_fragment":
		_tutorial_awaiting_power_up = ""
		_hud.set_map_highlighted(true)
		_tutorial_awaiting_map = true
		var caption: Label = _current_room.get_node_or_null("Caption")
		if caption:
			caption.text = "Tap Map to see what you've discovered."

func _on_fragment_use_anyway_pressed() -> void:
	_use_map_fragment()

func _on_fragment_cancel_pressed() -> void:
	pass

func _on_warp_pressed() -> void:
	if GameState.get_charges("warp_scroll") <= 0:
		return
	var current_room_id: String = LevelLoader.current_room_data.room_id
	var options: Array = []
	for room_id in GameState.get_visited_rooms():
		if room_id == current_room_id:
			continue
		var room: RoomData = LevelLoader.current_level.get_room(room_id)
		var room_name: String = room.get_display_name(LevelLoader.current_level) if room else room_id
		options.append({"id": room_id, "name": room_name})
	_hud.show_warp_picker(options)

func _on_warp_room_selected(room_id: String) -> void:
	_hud.hide_warp_picker()
	GameState.consume("warp_scroll")
	if _tutorial_awaiting_power_up == "warp_scroll":
		_tutorial_awaiting_power_up = ""
		_hud.set_warp_highlighted(false)
	LevelLoader.enter_room(room_id)

func _on_warp_cancel_pressed() -> void:
	_hud.hide_warp_picker()

func _on_map_pressed() -> void:
	_hud.show_map_overlay(_build_map_text())

func _build_map_text() -> String:
	var current_room_id: String = LevelLoader.current_room_data.room_id
	var lines: Array[String] = []
	lines.append("Visited Rooms:")
	for room_id in GameState.get_visited_rooms():
		var room: RoomData = LevelLoader.current_level.get_room(room_id)
		var room_name: String = room.get_display_name(LevelLoader.current_level) if room else room_id
		if room_id == current_room_id:
			lines.append("- [b]%s — You are here[/b]" % room_name)
		else:
			lines.append("- %s" % room_name)

	if GameState.has_map_fragment_snapshot():
		lines.append("")
		lines.append("Known Connections:")
		var snapshot: Dictionary = GameState.map_fragment_snapshot
		for from_room_id in snapshot:
			var from_room: RoomData = LevelLoader.current_level.get_room(from_room_id)
			var from_name: String = from_room.get_display_name(LevelLoader.current_level) if from_room else from_room_id
			for entry in snapshot[from_room_id]:
				var to_room: RoomData = LevelLoader.current_level.get_room(entry["to"])
				var to_name: String = to_room.get_display_name(LevelLoader.current_level) if to_room else entry["to"]
				var color_hex: String = (entry["color"] as Color).to_html(false)
				lines.append("- %s -> [color=#%s]%s Portal[/color] -> %s" % [from_name, color_hex, entry["label"], to_name])

	return "\n".join(lines)

func _unhandled_input(event: InputEvent) -> void:
	var tapped: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed)
	if not tapped:
		return

	if _hud.is_reveal_visible():
		_hud.hide_reveal()
		return

	if _hud.is_map_overlay_visible():
		_hud.hide_map_overlay()
		if _tutorial_awaiting_map:
			_tutorial_awaiting_map = false
			_hud.set_map_highlighted(false)
			var caption: Label = _current_room.get_node_or_null("Caption")
			if caption:
				caption.text = "Tap the portal to continue."
		return

	if _level_complete or _level_failed:
		return

	if _tutorial_awaiting_power_up != "" or _tutorial_awaiting_map:
		return

	if GameState.armed_power_up == "compass":
		var armed_point: Vector2 = get_global_mouse_position()
		for tappable in _get_room_tappables():
			if tappable is Portal and tappable.contains_point(armed_point):
				_reveal_portal_destination(tappable)
				return
		if _tutorial_forcing_compass_reveal:
			return
		GameState.disarm()
		_hud.set_compass_armed(false)
		return

	var point: Vector2 = get_global_mouse_position()

	if _tutorial_lock_target:
		if _tutorial_lock_target.contains_point(point):
			_tutorial_lock_target.trigger()
		return

	for tappable in _get_room_tappables():
		if tappable.contains_point(point):
			tappable.trigger()
			return

func _reveal_portal_destination(portal: Portal) -> void:
	var dest_room: RoomData = LevelLoader.current_level.get_room(portal.destination_room_id)
	var dest_display_name: String = dest_room.get_display_name(LevelLoader.current_level) if dest_room else ""
	var dest_name: String = dest_display_name if dest_display_name != "" else "an unknown room"
	GameState.record_known_connection(LevelLoader.current_room_data.room_id, portal.destination_room_id, portal.portal_label, portal.portal_color)
	_hud.show_reveal("Leads to %s." % dest_name)
	GameState.consume("compass")
	_hud.set_compass_armed(false)
	_tutorial_forcing_compass_reveal = false

func _on_portal_entered(destination_room_id: String, portal: Node2D) -> void:
	var from_room_id: String = LevelLoader.current_room_data.room_id
	GameState.record_known_connection(from_room_id, destination_room_id, portal.portal_label, portal.portal_color)
	GameState.consume_move()
	_hud.set_moves_label(GameState.moves_remaining, GameState.has_unlimited_moves())
	if _player:
		_player.move_to(portal.global_position)
	await get_tree().create_timer(0.2).timeout
	LevelLoader.enter_room(destination_room_id)

func _on_door_opened(door: Node2D) -> void:
	if _player:
		_player.move_to(door.global_position)
	_level_complete = true
	var caption: Label = _current_room.get_node_or_null("Caption")
	if caption:
		caption.text = "Level Complete!"

	var moves_used: int = GameState.get_moves_used()
	var stars: int = LevelLoader.current_level.get_star_rating(moves_used)
	_hud.show_stars(stars, moves_used, GameState.has_unlimited_moves())
	_hud.set_utility_buttons_disabled(true)

	_pending_next_level_path = LevelLoader.current_level.next_level_path
	_hud.set_continue_visible(_pending_next_level_path != "")

func _on_continue_pressed() -> void:
	if _pending_next_level_path == "":
		return
	var next_level_path: String = _pending_next_level_path
	_pending_next_level_path = ""
	_hud.set_continue_visible(false)
	_start_level(next_level_path)

func _on_retry_pressed() -> void:
	_start_level(_current_level_path)
