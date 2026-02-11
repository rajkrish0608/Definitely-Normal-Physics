## TouchControls — Mobile Virtual Joystick + Jump Button (CanvasLayer)
##
## Provides on-screen controls for mobile devices.
## Auto-hides on desktop platforms.
##
## ── Scene Structure (create manually in Godot) ──
## TouchControls (CanvasLayer)
## ├── JoystickBase (Control, left side)
## │   ├── BaseSprite (ColorRect or Sprite2D)
## │   └── StickSprite (ColorRect or Sprite2D)
## └── JumpButton (TouchScreenButton, right side)
extends CanvasLayer


# ─── Configuration ───────────────────────────────────────────────────────────

## Dead zone as fraction of joystick radius (0.0 - 1.0).
@export var joystick_dead_zone: float = 0.15

## Joystick radius in pixels.
@export var joystick_radius: float = 80.0


# ─── State ───────────────────────────────────────────────────────────────────

## Current joystick axis value (-1.0 to 1.0, horizontal).
var _axis: float = 0.0

## Touch ID currently controlling the joystick.
var _joystick_touch_id: int = -1

## Starting position of the joystick touch.
var _joystick_start_pos: Vector2 = Vector2.ZERO


# ─── Nodes ───────────────────────────────────────────────────────────────────

@onready var joystick_base := $JoystickBase as Control
@onready var stick_sprite := $JoystickBase/StickSprite as Control
@onready var jump_button := $JumpButton as TouchScreenButton


# ─── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
	# Hide on non-mobile platforms
	if not OS.has_feature("mobile"):
		hide()
		return

	# Position controls initially
	_update_positions()
	
	# Connect to viewport size change signal
	get_viewport().size_changed.connect(_update_positions)
	
	if jump_button:
		jump_button.pressed.connect(_on_jump_pressed)


## Updates positions based on current viewport size.
func _update_positions() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if joystick_base:
		joystick_base.position = Vector2(120, viewport_size.y - 120)
	
	if jump_button:
		jump_button.position = Vector2(viewport_size.x - 150, viewport_size.y - 120)


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


# ─── Joystick Input ─────────────────────────────────────────────────────────

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Check if touch is in joystick area
		var local_pos := event.position - joystick_base.global_position
		if local_pos.length() < joystick_radius * 2:
			_joystick_touch_id = event.index
			_joystick_start_pos = event.position
	else:
		# Release
		if event.index == _joystick_touch_id:
			_joystick_touch_id = -1
			_axis = 0.0
			_reset_stick()


func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index != _joystick_touch_id:
		return

	var delta := event.position - _joystick_start_pos
	var distance := delta.length()
	var direction := delta.normalized()

	# Clamp to joystick radius
	if distance > joystick_radius:
		distance = joystick_radius

	# Apply dead zone
	var normalized_distance := distance / joystick_radius
	if normalized_distance < joystick_dead_zone:
		_axis = 0.0
	else:
		_axis = direction.x * normalized_distance

	# Update stick visual position
	if stick_sprite:
		stick_sprite.position = direction * distance


func _reset_stick() -> void:
	if stick_sprite:
		stick_sprite.position = Vector2.ZERO


# ─── Jump Button ────────────────────────────────────────────────────────────

func _on_jump_pressed() -> void:
	Input.action_press("jump")
	await get_tree().create_timer(0.1).timeout
	Input.action_release("jump")


# ─── Public API ─────────────────────────────────────────────────────────────

## Returns the current horizontal axis (-1.0 to 1.0).
## Can be used by PlayerController instead of Input.get_axis().
func get_axis() -> float:
	return _axis
