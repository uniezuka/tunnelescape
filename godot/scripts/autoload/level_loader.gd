extends Node

signal room_loaded(room_node: Node2D, room_data: RoomData)

var current_level: LevelData
var current_room_data: RoomData
var current_room_node: Node2D

var _container: Node

func start_level(level: LevelData, container: Node) -> void:
	current_level = level
	_container = container
	_enter_room(level.starting_room_id)

func enter_room(room_id: String) -> void:
	_enter_room(room_id)

func _enter_room(room_id: String) -> void:
	var room_data: RoomData = current_level.get_room(room_id)
	if room_data == null:
		push_error("LevelLoader: unknown room id '%s'" % room_id)
		return

	if current_room_node:
		current_room_node.queue_free()

	current_room_node = room_data.scene.instantiate()
	current_room_data = room_data
	_container.add_child(current_room_node)
	room_loaded.emit(current_room_node, room_data)
