extends Tappable
class_name Tunnel

signal tunnel_entered(destination_room_id: String)

@export var tunnel_color: Color = Color.WHITE
@export var tunnel_label: String = "Unknown"
@export var destination_room_id: String = ""

@onready var _visual: Polygon2D = $Polygon2D

func _ready() -> void:
	super._ready()
	_visual.color = tunnel_color

func _on_trigger() -> void:
	tunnel_entered.emit(destination_room_id)
