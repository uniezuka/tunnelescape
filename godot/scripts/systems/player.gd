extends Node2D

const RADIUS := 36.0
const COLOR := Color(1.0, 0.85, 0.1, 1)

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, COLOR)

func move_to(target_position: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_position, 0.2)
