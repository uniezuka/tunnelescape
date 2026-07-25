extends Node2D

func move_to(target_position: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_position, 0.2)
