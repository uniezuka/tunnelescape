extends Node2D
class_name Tappable

@export var tap_half_width: float = 48.0
@export var tap_half_height: float = 48.0
@export var tutorial_highlight: bool = false

var _highlight_tween: Tween

func _ready() -> void:
	add_to_group("tappables")
	if tutorial_highlight:
		set_highlighted(true)

func contains_point(point: Vector2) -> bool:
	var local: Vector2 = point - global_position
	return absf(local.x) <= tap_half_width and absf(local.y) <= tap_half_height

func trigger() -> void:
	set_highlighted(false)
	_on_trigger()

func _on_trigger() -> void:
	pass

func set_highlighted(active: bool) -> void:
	if _highlight_tween:
		_highlight_tween.kill()
	scale = Vector2.ONE
	if active:
		_highlight_tween = create_tween().set_loops()
		_highlight_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.5)
		_highlight_tween.tween_property(self, "scale", Vector2.ONE, 0.5)
