extends Area2D

signal tunnel_entered(destination_room_id: String)

@export var tunnel_color: Color = Color.WHITE
@export var destination_room_id: String = ""
@export var tap_half_size: float = 48.0

@onready var _visual: Polygon2D = $Polygon2D

func _ready() -> void:
	_visual.color = tunnel_color
	add_to_group("tunnels")

func contains_point(point: Vector2) -> bool:
	var local: Vector2 = point - global_position
	return absf(local.x) <= tap_half_size and absf(local.y) <= tap_half_size

func trigger() -> void:
	tunnel_entered.emit(destination_room_id)
