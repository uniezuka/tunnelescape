extends Resource
class_name LevelData

@export var level_id: String = ""
@export var move_limit: int = -1
@export var starting_room_id: String = ""
@export var rooms: Array[RoomData] = []

func get_room(room_id: String) -> RoomData:
	for room in rooms:
		if room.room_id == room_id:
			return room
	return null
