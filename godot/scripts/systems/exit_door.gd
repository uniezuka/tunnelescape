extends Tappable
class_name ExitDoor

signal door_opened

@export var door_color: Color = Color(0.55, 0.38, 0.2)

@onready var _visual: Polygon2D = $Polygon2D

func _ready() -> void:
	super._ready()
	_visual.color = door_color

func _on_trigger() -> void:
	door_opened.emit()
