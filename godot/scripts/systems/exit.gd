extends Area2D

signal exit_reached

@export var exit_color: Color = Color(0.2, 0.8, 0.3)
@export var tap_half_size: float = 56.0

@onready var _visual: Polygon2D = $Polygon2D

func _ready() -> void:
	_visual.color = exit_color
	add_to_group("exit")

func contains_point(point: Vector2) -> bool:
	var local: Vector2 = point - global_position
	return absf(local.x) <= tap_half_size and absf(local.y) <= tap_half_size

func trigger() -> void:
	exit_reached.emit()
