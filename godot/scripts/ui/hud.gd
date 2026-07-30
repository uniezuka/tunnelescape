extends CanvasLayer
class_name HUD

signal compass_pressed
signal continue_pressed
signal retry_pressed
signal map_pressed
signal fragment_pressed
signal fragment_use_anyway_pressed
signal fragment_cancel_pressed
signal warp_pressed
signal warp_room_selected(room_id: String)
signal warp_cancel_pressed

@onready var _level_label: Label = $Root/LevelLabel
@onready var _moves_label: Label = $Root/MovesLabel
@onready var _compass_button: Button = $Root/CompassButton
@onready var _stars_label: Label = $Root/StarsLabel
@onready var _continue_button: Button = $Root/ContinueButton
@onready var _reveal_popup: Control = $Root/RevealPopup
@onready var _reveal_label: Label = $Root/RevealPopup/RevealLabel

@onready var _fail_overlay: Control = $Root/FailOverlay
@onready var _retry_button: Button = $Root/FailOverlay/RetryButton

@onready var _map_button: Button = $Root/MapButton
@onready var _map_overlay: Control = $Root/MapOverlay
@onready var _map_label: RichTextLabel = $Root/MapOverlay/MapLabel

@onready var _fragment_button: Button = $Root/FragmentButton
@onready var _fragment_confirm: Control = $Root/FragmentConfirmDialog
@onready var _fragment_use_anyway_button: Button = $Root/FragmentConfirmDialog/UseAnywayButton
@onready var _fragment_cancel_button: Button = $Root/FragmentConfirmDialog/CancelButton

@onready var _warp_button: Button = $Root/WarpButton
@onready var _warp_picker: Control = $Root/WarpPicker
@onready var _warp_room_list: VBoxContainer = $Root/WarpPicker/RoomList
@onready var _warp_cancel_button: Button = $Root/WarpPicker/CancelButton

var _compass_highlight_tween: Tween
var _fragment_highlight_tween: Tween
var _map_highlight_tween: Tween
var _warp_highlight_tween: Tween

func _ready() -> void:
	_compass_button.pressed.connect(func(): compass_pressed.emit())
	_continue_button.pressed.connect(func(): continue_pressed.emit())
	_map_button.pressed.connect(func(): map_pressed.emit())
	_fragment_button.pressed.connect(func(): fragment_pressed.emit())
	_fragment_use_anyway_button.pressed.connect(func():
		_fragment_confirm.visible = false
		fragment_use_anyway_pressed.emit())
	_fragment_cancel_button.pressed.connect(func():
		_fragment_confirm.visible = false
		fragment_cancel_pressed.emit())
	_warp_button.pressed.connect(func(): warp_pressed.emit())
	_warp_cancel_button.pressed.connect(func():
		_warp_picker.visible = false
		warp_cancel_pressed.emit())
	_retry_button.pressed.connect(func(): retry_pressed.emit())

func set_continue_visible(continue_visible: bool) -> void:
	_continue_button.visible = continue_visible

func set_level_label(level_number: int) -> void:
	_level_label.text = "Level %d" % level_number

func set_moves_label(moves_remaining: int, unlimited: bool) -> void:
	_moves_label.text = "" if unlimited else "Moves: %d" % moves_remaining

func show_stars(stars: int, moves_used: int, unlimited: bool) -> void:
	var stars_text: String = "⭐".repeat(stars)
	_stars_label.text = stars_text if unlimited else "%s (%d moves)" % [stars_text, moves_used]
	_stars_label.visible = true

func hide_stars() -> void:
	_stars_label.visible = false

func show_fail_overlay() -> void:
	_fail_overlay.visible = true
	_set_buttons_disabled(true)

func hide_fail_overlay() -> void:
	_fail_overlay.visible = false
	_set_buttons_disabled(false)

func set_utility_buttons_disabled(disabled: bool) -> void:
	_compass_button.disabled = disabled
	_fragment_button.disabled = disabled
	_warp_button.disabled = disabled
	_map_button.disabled = disabled

func set_compass_visible(compass_visible: bool) -> void:
	_compass_button.visible = compass_visible

func set_compass_armed(armed: bool) -> void:
	_compass_button.modulate = Color(1, 0.85, 0.3) if armed else Color.WHITE

func set_compass_highlighted(active: bool) -> void:
	if _compass_highlight_tween:
		_compass_highlight_tween.kill()
	_compass_button.scale = Vector2.ONE
	if active:
		_compass_highlight_tween = create_tween().set_loops()
		_compass_highlight_tween.tween_property(_compass_button, "scale", Vector2(1.15, 1.15), 0.5)
		_compass_highlight_tween.tween_property(_compass_button, "scale", Vector2.ONE, 0.5)

func set_fragment_visible(fragment_visible: bool) -> void:
	_fragment_button.visible = fragment_visible

func set_fragment_highlighted(active: bool) -> void:
	if _fragment_highlight_tween:
		_fragment_highlight_tween.kill()
	_fragment_button.scale = Vector2.ONE
	if active:
		_fragment_highlight_tween = create_tween().set_loops()
		_fragment_highlight_tween.tween_property(_fragment_button, "scale", Vector2(1.15, 1.15), 0.5)
		_fragment_highlight_tween.tween_property(_fragment_button, "scale", Vector2.ONE, 0.5)

func set_map_visible(map_visible: bool) -> void:
	_map_button.visible = map_visible

func set_map_highlighted(active: bool) -> void:
	if _map_highlight_tween:
		_map_highlight_tween.kill()
	_map_button.scale = Vector2.ONE
	if active:
		_map_highlight_tween = create_tween().set_loops()
		_map_highlight_tween.tween_property(_map_button, "scale", Vector2(1.15, 1.15), 0.5)
		_map_highlight_tween.tween_property(_map_button, "scale", Vector2.ONE, 0.5)

func set_warp_visible(warp_visible: bool) -> void:
	_warp_button.visible = warp_visible

func set_warp_highlighted(active: bool) -> void:
	if _warp_highlight_tween:
		_warp_highlight_tween.kill()
	_warp_button.scale = Vector2.ONE
	if active:
		_warp_highlight_tween = create_tween().set_loops()
		_warp_highlight_tween.tween_property(_warp_button, "scale", Vector2(1.15, 1.15), 0.5)
		_warp_highlight_tween.tween_property(_warp_button, "scale", Vector2.ONE, 0.5)

func show_warp_picker(rooms: Array) -> void:
	for child in _warp_room_list.get_children():
		child.queue_free()
	for room in rooms:
		var button := Button.new()
		button.text = room["name"]
		button.custom_minimum_size = Vector2(0, 100)
		button.add_theme_font_size_override("font_size", 40)
		button.pressed.connect(_on_warp_room_button_pressed.bind(room["id"]))
		_warp_room_list.add_child(button)
	_warp_picker.visible = true

func _on_warp_room_button_pressed(room_id: String) -> void:
	warp_room_selected.emit(room_id)

func hide_warp_picker() -> void:
	_warp_picker.visible = false

func show_reveal(text: String) -> void:
	_reveal_label.text = text
	_reveal_popup.visible = true
	_set_buttons_disabled(true)

func hide_reveal() -> void:
	_reveal_popup.visible = false
	_set_buttons_disabled(false)

func is_reveal_visible() -> bool:
	return _reveal_popup.visible

func show_map_overlay(text: String) -> void:
	_map_label.text = text
	_map_overlay.visible = true
	_set_buttons_disabled(true)

func hide_map_overlay() -> void:
	_map_overlay.visible = false
	_set_buttons_disabled(false)

func is_map_overlay_visible() -> bool:
	return _map_overlay.visible

func show_fragment_confirm() -> void:
	_fragment_confirm.visible = true

func _set_buttons_disabled(disabled: bool) -> void:
	# RevealPopup/MapOverlay use mouse_filter=Ignore so a tap-anywhere-to-dismiss
	# can reach main.gd's world input — but that also lets it fall through onto
	# any other button hidden underneath the popup's backdrop. Disabling the
	# other buttons while a popup is open closes that gap.
	_compass_button.disabled = disabled
	_fragment_button.disabled = disabled
	_map_button.disabled = disabled
	_continue_button.disabled = disabled
	_warp_button.disabled = disabled
