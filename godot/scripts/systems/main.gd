extends Node2D

@onready var _room_container: Node2D = $RoomContainer

var _current_room: Node2D
var _player: Node2D
var _tutorial_lock_target: Node2D
var _level_complete: bool = false

func _ready() -> void:
	LevelLoader.room_loaded.connect(_on_room_loaded)
	var level: LevelData = load("res://resources/levels/level_01.tres")
	LevelLoader.start_level(level, _room_container)

func _on_room_loaded(room_node: Node2D, room_data: RoomData) -> void:
	_current_room = room_node
	_level_complete = false
	_tutorial_lock_target = null
	_player = room_node.get_node("Player")

	for tappable in _get_room_tappables():
		if tappable is Tunnel:
			tappable.tunnel_entered.connect(_on_tunnel_entered.bind(tappable))
		elif tappable is ExitDoor:
			tappable.door_opened.connect(_on_door_opened.bind(tappable))
		if tappable.tutorial_highlight:
			_tutorial_lock_target = tappable

func _get_room_tappables() -> Array:
	var tappables: Array = []
	for node in get_tree().get_nodes_in_group("tappables"):
		if _current_room.is_ancestor_of(node):
			tappables.append(node)
	return tappables

func _input(event: InputEvent) -> void:
	if _level_complete:
		return

	var tapped: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed)
	if not tapped:
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

func _on_tunnel_entered(destination_room_id: String, tunnel: Node2D) -> void:
	if _player:
		_player.move_to(tunnel.global_position)
	await get_tree().create_timer(0.2).timeout
	LevelLoader.enter_room(destination_room_id)

func _on_door_opened(door: Node2D) -> void:
	if _player:
		_player.move_to(door.global_position)
	_level_complete = true
	var caption: Label = _current_room.get_node_or_null("Caption")
	if caption:
		caption.text = "Level Complete!"
