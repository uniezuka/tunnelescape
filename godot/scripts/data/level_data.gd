extends Resource
class_name LevelData

@export var level_id: String = ""
@export var level_number: int = 0
@export var next_level_path: String = ""
@export var move_limit: int = -1
@export var star_3_threshold: int = -1
@export var star_2_threshold: int = -1
@export var starting_room_id: String = ""
@export var starting_power_ups: Dictionary = {}
@export var starts_with_map_unlocked: bool = true
@export var theme: RoomTheme
@export var rooms: Array[RoomData] = []

func get_room(room_id: String) -> RoomData:
	for room in rooms:
		if room.room_id == room_id:
			return room
	return null

func get_star_rating(moves_used: int) -> int:
	if move_limit < 0 or star_3_threshold < 0:
		return 3
	if moves_used <= star_3_threshold:
		return 3
	if moves_used <= star_2_threshold:
		return 2
	return 1
