extends Resource
class_name RoomData

@export var room_id: String = ""
@export var room_name: String = ""
@export_enum("start", "other", "exit") var room_role: String = "other"
@export var scene: PackedScene
@export var requires_power_up: String = ""
@export var revisit_caption: String = ""

## "other" rooms are named directly via room_name. Start/Exit rooms are always
## named by the level's theme, so a missing theme (or a theme missing that
## name) is an authoring mistake, not a normal case to fall back from silently.
func get_display_name(level: LevelData) -> String:
	if room_role == "other":
		return room_name
	if level == null or level.theme == null:
		push_error("RoomData '%s' has room_role '%s' but its level has no theme assigned." % [room_id, room_role])
		return "(missing room name)"
	var themed_name: String = level.theme.start_room_name if room_role == "start" else level.theme.exit_room_name
	if themed_name == "":
		push_error("Theme '%s' has no %s_room_name set." % [level.theme.theme_id, room_role])
		return "(missing room name)"
	return themed_name
