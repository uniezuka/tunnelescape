extends Node

signal charges_changed(power_up_id: String, remaining: int)

var armed_power_up: String = ""
var map_fragment_snapshot: Dictionary = {}
var map_unlocked: bool = false

var _charges: Dictionary = {}
var _visited_rooms: Dictionary = {}       # room_id -> true
var _known_connections: Dictionary = {}   # from_room_id -> Array[{"to": String, "label": String}]

func start_level(level: LevelData) -> void:
	_charges.clear()
	armed_power_up = ""
	_visited_rooms.clear()
	_known_connections.clear()
	map_fragment_snapshot = {}
	map_unlocked = false
	for power_up_id in level.starting_power_ups:
		_charges[power_up_id] = level.starting_power_ups[power_up_id]
		charges_changed.emit(power_up_id, _charges[power_up_id])

func get_charges(power_up_id: String) -> int:
	return _charges.get(power_up_id, 0)

func arm(power_up_id: String) -> bool:
	if get_charges(power_up_id) <= 0:
		return false
	armed_power_up = power_up_id
	return true

func disarm() -> void:
	armed_power_up = ""

func consume(power_up_id: String) -> void:
	if get_charges(power_up_id) > 0:
		_charges[power_up_id] -= 1
		charges_changed.emit(power_up_id, _charges[power_up_id])
	armed_power_up = ""

func mark_visited(room_id: String) -> void:
	_visited_rooms[room_id] = true

func get_visited_rooms() -> Array:
	return _visited_rooms.keys()

func record_known_connection(from_room_id: String, destination_room_id: String, tunnel_label: String, tunnel_color: Color) -> void:
	if not _known_connections.has(from_room_id):
		_known_connections[from_room_id] = []
	for entry in _known_connections[from_room_id]:
		if entry["to"] == destination_room_id:
			return
	_known_connections[from_room_id].append({"to": destination_room_id, "label": tunnel_label, "color": tunnel_color})

func has_known_connections() -> bool:
	return not _known_connections.is_empty()

func snapshot_known_connections() -> void:
	map_fragment_snapshot = _known_connections.duplicate(true)

func has_map_fragment_snapshot() -> bool:
	return not map_fragment_snapshot.is_empty()

func unlock_map() -> void:
	map_unlocked = true
