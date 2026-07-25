extends Node2D

@onready var _player: Node2D = $Room01/Player

var _level_complete: bool = false

func _ready() -> void:
	for tunnel in get_tree().get_nodes_in_group("tunnels"):
		tunnel.tunnel_entered.connect(_on_tunnel_entered.bind(tunnel))
	for exit_node in get_tree().get_nodes_in_group("exit"):
		exit_node.exit_reached.connect(_on_exit_reached.bind(exit_node))

func _input(event: InputEvent) -> void:
	if _level_complete:
		return

	var tapped: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed)
	if not tapped:
		return

	var point: Vector2 = get_global_mouse_position()

	for exit_node in get_tree().get_nodes_in_group("exit"):
		if exit_node.contains_point(point):
			exit_node.trigger()
			return

	for tunnel in get_tree().get_nodes_in_group("tunnels"):
		if tunnel.contains_point(point):
			tunnel.trigger()
			return

func _on_tunnel_entered(destination_room_id: String, tunnel: Node2D) -> void:
	print("Tunnel entered -> would travel to: %s" % destination_room_id)
	_player.move_to(tunnel.global_position)

func _on_exit_reached(exit_node: Node2D) -> void:
	print("Exit reached -> level complete!")
	_player.move_to(exit_node.global_position)
	_level_complete = true
