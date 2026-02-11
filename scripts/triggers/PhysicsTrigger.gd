## PhysicsTrigger — Area2D that Changes Physics State (Scene Component)
##
## Place in levels to trigger physics changes when the player enters,
## exits, or after a timer.
##
## ── Usage ──
## 1. Create an Area2D node in your level
## 2. Attach this script
## 3. Add a CollisionShape2D child
## 4. Set collision layers: Layer 3 (Triggers), Mask 1 (Player)
## 5. Configure export variables in the Inspector
extends Area2D


# ─── Configuration ───────────────────────────────────────────────────────────

## Physics state to activate when triggered.
## Should match a state name from PhysicsManager (e.g., "ReverseGravity").
@export var target_physics_state: String = "Normal"

## How the trigger activates:
## - "enter": Trigger when player enters the area
## - "exit": Trigger when player leaves the area
## - "timer": Trigger X seconds after player enters
@export_enum("enter", "exit", "timer") var trigger_type: String = "enter"

## Delay in seconds before triggering (used for all types).
@export var delay: float = 0.0

## If true, trigger can only fire once. If false, it resets when player leaves.
@export var one_time: bool = false

## Enable to see trigger bounds in-game (for debugging).
@export var debug_visible: bool = false


# ─── State ───────────────────────────────────────────────────────────────────

## True if this trigger has already fired (for one_time mode).
var _triggered: bool = false

## Active timer for delayed triggers.
var _timer: Timer = null


# ─── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
	# Ensure correct collision setup
	collision_layer = 0b100  # Layer 3
	collision_mask = 0b001   # Layer 1 (Player)

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Debug visualization
	if debug_visible:
		_show_debug_bounds()


# ─── Trigger Logic ──────────────────────────────────────────────────────────

## Called when a body enters the trigger area.
func _on_body_entered(body: Node2D) -> void:
	if not _is_player(body) or _triggered:
		return

	match trigger_type:
		"enter":
			_fire_trigger()
		"timer":
			_start_timer()


## Called when a body exits the trigger area.
func _on_body_exited(body: Node2D) -> void:
	if not _is_player(body):
		return

	if trigger_type == "exit":
		_fire_trigger()
	elif trigger_type == "timer" and _timer:
		# Cancel timer if player leaves before it fires
		_timer.stop()

	# Reset for repeatable triggers
	if not one_time:
		_triggered = false


## Activates the physics state change.
func _fire_trigger() -> void:
	if delay > 0:
		await get_tree().create_timer(delay).timeout

	if not PhysicsManager.has_state(target_physics_state):
		push_error("[PhysicsTrigger] Unknown state: %s" % target_physics_state)
		return

	PhysicsManager.set_state(target_physics_state)
	_triggered = true


## Starts a timer for "timer" trigger type.
func _start_timer() -> void:
	if not _timer:
		_timer = Timer.new()
		_timer.one_shot = true
		_timer.timeout.connect(_fire_trigger)
		add_child(_timer)

	_timer.wait_time = delay if delay > 0 else 0.1
	_timer.start()


# ─── Helpers ────────────────────────────────────────────────────────────────

## Returns true if the body is on the Player layer.
func _is_player(body: Node2D) -> bool:
	if body is CharacterBody2D:
		return body.collision_layer & 0b001  # Layer 1 = Player
	return false


## Draws a semi-transparent rectangle showing trigger bounds (debug mode).
func _show_debug_bounds() -> void:
	var shape := get_node_or_null("CollisionShape2D")
	if not shape or not shape.shape:
		return

	var rect_shape := shape.shape as RectangleShape2D
	if not rect_shape:
		return

	var debug_rect := ColorRect.new()
	debug_rect.color = Color(1, 0, 0, 0.2)  # Semi-transparent red
	debug_rect.size = rect_shape.size
	debug_rect.position = -rect_shape.size / 2
	shape.add_child(debug_rect)
