## PlayerAnimator — Animation State Machine (AnimatedSprite2D)
##
## Reads parent CharacterBody2D velocity to determine animation state.
## Responds to physics changes (e.g., flips upside-down in reverse gravity).
##
## ── Required Setup ──
## 1. Attach to AnimatedSprite2D node (child of Player CharacterBody2D)
## 2. Create SpriteFrames with animations: idle, run, jump, fall, death
## 3. Ensure parent has PlayerController.gd attached
extends AnimatedSprite2D


## Emitted when a specific frame event is triggered (e.g. "footstep").
signal frame_event_triggered(event_name: String)


# ─── State ───────────────────────────────────────────────────────────────────

## Reference to parent player controller.
var _player: CharacterBody2D = null

## Current animation state (to avoid redundant play() calls).
var _current_anim: String = ""

## Last horizontal direction (-1 = left, 1 = right).
var _last_direction: int = 1


# ─── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
	_player = get_parent() as CharacterBody2D
	if not _player:
		push_error("[PlayerAnimator] Parent must be CharacterBody2D with PlayerController.gd")
		return

	# Listen to frame changes for triggers
	frame_changed.connect(_on_frame_changed)
	
	# Listen to physics changes for visual effects
	EventBus.physics_changed.connect(_on_physics_changed)


func _on_frame_changed() -> void:
	# Boilerplate for frame-specific events (e.g. footsteps on frames 2 and 5 of run)
	if animation == "run":
		if frame == 1 or frame == 4:
			frame_event_triggered.emit("footstep")
			if AudioManager:
				AudioManager.play_sfx("footstep", 0.5)


func _process(_delta: float) -> void:
	if not _player:
		return

	# ── Determine animation based on velocity ──
	var anim_name := _determine_animation()
	if anim_name != _current_anim:
		_current_anim = anim_name
		play(anim_name)

	# ── Flip sprite based on movement direction ──
	if _player.velocity.x != 0:
		_last_direction = sign(_player.velocity.x) as int
		flip_h = _last_direction < 0


# ─── Animation Logic ────────────────────────────────────────────────────────

## Determines which animation to play based on player state.
func _determine_animation() -> String:
	# Death animation takes priority
	if _current_anim == "death" and is_playing():
		return "death"

	var vel := _player.velocity
	var on_floor := _player.is_on_floor()

	if not on_floor:
		# Check if moving up or down relative to gravity
		var gravity_dir := PhysicsManager.get_current_gravity().normalized()
		var vertical_vel := vel.dot(gravity_dir)
		if vertical_vel < -50:  # Moving against gravity = jumping
			return "jump"
		else:  # Falling with gravity
			return "fall"
	else:
		# On ground
		if abs(vel.x) > 10:  # Moving horizontally
			return "run"
		else:
			return "idle"


# ─── Physics Change Response ────────────────────────────────────────────────

## Called when PhysicsManager switches states.
## Rotates sprite if gravity is reversed.
func _on_physics_changed(state_name: String) -> void:
	var gravity_dir := PhysicsManager.get_current_gravity().normalized()

	# Flip sprite upside-down if gravity is reversed
	if gravity_dir.y < 0:  # Gravity pulls upward
		rotation_degrees = 180
	else:
		rotation_degrees = 0

	# Optional: Play a particle effect or tween for smooth rotation
	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees", rotation_degrees, 0.3).set_ease(Tween.EASE_OUT)
