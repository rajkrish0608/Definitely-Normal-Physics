## PlayerController — Main Character Movement (CharacterBody2D)
##
## Integrates with PhysicsManager to apply dynamic gravity, friction, bounce,
## speed/jump multipliers, and control modifiers (reversal, input delay).
##
## ── Usage ──
## 1. Create a CharacterBody2D node named "Player"
## 2. Attach this script
## 3. Add a CollisionShape2D child
## 4. Add an AnimatedSprite2D child with PlayerAnimator.gd attached
## 5. (Optional) Add a Camera2D child for following
extends CharacterBody2D


# ─── Constants ───────────────────────────────────────────────────────────────

## Base horizontal movement speed (pixels/second).
const BASE_SPEED: float = 300.0

## Base jump velocity (negative = upward).
const BASE_JUMP_VELOCITY: float = -500.0

## Acceleration when starting/changing direction (pixels/s²).
const ACCELERATION: float = 2000.0

## Fall-off detection: if player falls below this Y, trigger death.
const DEATH_FALL_Y: float = 2000.0


# ─── State ───────────────────────────────────────────────────────────────────

## Input delay queue: array of {action: String, timestamp: float}
var _input_queue: Array = []

## True while the death animation/respawn is happening.
var _is_dead: bool = false

## Coyote time: allow jump shortly after leaving ground.
var _coyote_timer: float = 0.0
const COYOTE_TIME: float = 0.1


# ─── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
	# Register camera with ScreenEffects if present
	var cam := get_node_or_null("Camera2D")
	if cam:
		ScreenEffects.register_camera(cam)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	# ── Death detection ──
	if global_position.y > DEATH_FALL_Y:
		die()
		return

	# ── Gravity ──
	var gravity := PhysicsManager.get_current_gravity()
	if not is_on_floor():
		velocity += gravity * delta
		_coyote_timer -= delta
	else:
		_coyote_timer = COYOTE_TIME
		# Apply bounce if landing
		if velocity.dot(gravity.normalized()) > 0 and PhysicsManager.current_state.bounce > 0:
			var bounce_factor := PhysicsManager.current_state.bounce
			velocity = velocity.reflect(Vector2.UP) * bounce_factor

	# ── Get physics multipliers ──
	var speed_mult := PhysicsManager.get_current_speed_multiplier()
	var jump_mult := PhysicsManager.get_current_jump_multiplier()
	var friction := PhysicsManager.get_current_friction()
	var controls_reversed := PhysicsManager.current_state.controls_reversed
	var input_delay := PhysicsManager.current_state.input_delay

	# ── Horizontal movement ──
	var input_dir := _get_input_direction(controls_reversed, input_delay, delta)
	var target_speed := input_dir * BASE_SPEED * speed_mult

	if input_dir != 0:
		# Accelerate toward target speed
		velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)
	else:
		# Apply friction
		var decel := ACCELERATION * (1.0 + friction) * delta
		velocity.x = move_toward(velocity.x, 0, decel)

	# ── Jump ──
	if _is_jump_pressed(input_delay, delta):
		if is_on_floor() or _coyote_timer > 0:
			# Determine jump direction based on gravity
			var jump_dir := -gravity.normalized()
			velocity += jump_dir * BASE_JUMP_VELOCITY * jump_mult
			_coyote_timer = 0  # Consume coyote time

	# ── Apply movement ──
	move_and_slide()

	# ── Collision-based death (hazards on layer 2) ──
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider and collider.collision_layer & 0b10:  # Layer 2 = hazards
			die()
			break


# ─── Input Handling ─────────────────────────────────────────────────────────

## Returns -1 (left), 0 (neutral), or +1 (right).
func _get_input_direction(reversed: bool, delay: float, delta: float) -> float:
	var raw_dir := Input.get_axis("move_left", "move_right")
	if reversed:
		raw_dir = -raw_dir

	if delay > 0:
		# Queue-based delay (simplified: just delay the entire input)
		# For proper implementation, track each action separately
		return raw_dir  # TODO: Implement proper input delay queue
	return raw_dir


## Returns true if jump was just pressed (with optional delay).
func _is_jump_pressed(delay: float, delta: float) -> bool:
	if delay > 0:
		# TODO: Implement input delay queue
		return Input.is_action_just_pressed("jump")
	return Input.is_action_just_pressed("jump")


# ─── Death & Respawn ────────────────────────────────────────────────────────

## Triggers death sequence.
func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	velocity = Vector2.ZERO
	EventBus.player_died.emit()

	# Play death animation via animator (if exists)
	var animator := get_node_or_null("AnimatedSprite2D")
	if animator and animator.sprite_frames and animator.sprite_frames.has_animation("death"):
		animator.play("death")
		await animator.animation_finished

	# Respawn handled by LevelManager
	_is_dead = false


## Called by LevelManager to respawn at checkpoint.
func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	_is_dead = false
	EventBus.player_respawned.emit(spawn_position)
