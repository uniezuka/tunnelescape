extends Tappable
class_name Portal

signal portal_entered(destination_room_id: String)

@export var portal_color: Color = Color.WHITE
@export var portal_label: String = "Unknown"
@export var destination_room_id: String = ""

@onready var _visual: Polygon2D = $Polygon2D

func _ready() -> void:
	super._ready()
	_visual.color = portal_color

func _on_trigger() -> void:
	portal_entered.emit(destination_room_id)
