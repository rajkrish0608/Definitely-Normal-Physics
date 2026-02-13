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

## Track whether we were on the floor last frame (for landing detection).
var _was_on_floor: bool = false

## Track last velocity for landing impact calculation.
var _last_velocity_y: float = 0.0


# ─── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
	# Register camera with ScreenEffects if present
	var cam := get_node_or_null("Camera2D")
	if cam:
		ScreenEffects.register_camera(cam)

	# Listen for physics changes to trigger visual feedback
	EventBus.physics_changed.connect(_on_physics_changed)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	# ── Death detection ──
	if global_position.y > DEATH_FALL_Y:
		die()
		return

	# ── Gravity ──
	var gravity: Vector2 = PhysicsManager.get_current_gravity()
	if not is_on_floor():
		velocity += gravity * delta
		_coyote_timer = max(0, _coyote_timer - delta)
		_last_velocity_y = velocity.y
	else:
		_coyote_timer = GameConstants.COYOTE_TIME
		# Apply bounce if landing
		if velocity.dot(gravity.normalized()) > 0 and PhysicsManager.current_state.bounce > 0:
			var bounce_factor := PhysicsManager.current_state.bounce
			velocity = velocity.reflect(Vector2.UP) * bounce_factor

		# ── Landing detection: trigger effects ──
		if not _was_on_floor:
			var impact_speed := absf(_last_velocity_y)
			if impact_speed > 200:
				# Screen shake proportional to impact
				var shake_intensity := clampf(impact_speed / 100.0, 2.0, 12.0)
				ScreenEffects.shake_camera(shake_intensity, 0.15)
				ParticleFactory.land_dust(global_position + Vector2(0, 16))
				AudioManager.play_sfx("land")

	# ── Get physics multipliers ──
	var speed_mult: float = PhysicsManager.get_current_speed_multiplier()
	var jump_mult: float = PhysicsManager.get_current_jump_multiplier()
	var friction: float = PhysicsManager.get_current_friction()
	var controls_reversed := PhysicsManager.current_state.controls_reversed
	var input_delay := PhysicsManager.current_state.input_delay

	# ── Horizontal movement ──
	var input_dir := _get_input_direction(controls_reversed, input_delay, delta)
	var target_speed := input_dir * BASE_SPEED * speed_mult

	if input_dir != 0:
		# Accelerate toward target speed
		velocity.x = move_toward(velocity.x, target_speed, ACCELERATION if is_on_floor() else ACCELERATION * 0.5 * delta)
	else:
		# Apply friction
		var decel: float = ACCELERATION * (1.0 + friction) * delta
		velocity.x = move_toward(velocity.x, 0, decel)

	# ── Jump ──
	if _is_jump_pressed(input_delay, delta):
		if is_on_floor() or _coyote_timer > 0 or PhysicsManager.current_state.get_state_name() == "DoubleJump":
			# Use the state's handle_jump for custom logic
			velocity = PhysicsManager.current_state.handle_jump(self, velocity, BASE_JUMP_VELOCITY * jump_mult)
			_coyote_timer = 0  # Consume coyote time

	# ── Apply movement ──
	move_and_slide()

	# ── Collision-based death (hazards on layer 4) ──
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider and collider.collision_layer & 0b1000:  # Layer 4 = hazards
			die()
			break

	# ── Update floor tracking ──
	_was_on_floor = is_on_floor()


# ─── Input Handling ─────────────────────────────────────────────────────────

## Returns -1 (left), 0 (neutral), or +1 (right).
func _get_input_direction(reversed: bool, delay: float, _delta: float) -> float:
	var raw_dir: float = Input.get_axis("move_left", "move_right")
	if reversed:
		raw_dir = -raw_dir

	if delay > 0:
		_input_queue.append({
			"type": "axis",
			"value": raw_dir,
			"time": Time.get_ticks_msec() + (delay * 1000.0)
		})
		
		# Return the oldest valid axis value in the queue
		var current_time: int = Time.get_ticks_msec()
		var active_val := 0.0
		var to_remove := []
		
		for i in range(_input_queue.size()):
			var input = _input_queue[i]
			if input.type == "axis" and current_time >= input.time:
				active_val = input.value
				to_remove.append(i)
		
		# Clean up old entries (keep only the latest one that fired)
		for i in range(to_remove.size() - 1, -1, -1):
			_input_queue.remove_at(to_remove[i])
			
		return active_val
		
	return raw_dir


## Returns true if jump was just pressed (with optional delay).
func _is_jump_pressed(delay: float, _delta: float) -> bool:
	var pressed := Input.is_action_just_pressed("jump")
	
	if delay > 0:
		if pressed:
			_input_queue.append({
				"type": "jump",
				"time": Time.get_ticks_msec() + (delay * 1000.0)
			})
		
		var current_time: int = Time.get_ticks_msec()
		for i in range(_input_queue.size()):
			var input = _input_queue[i]
			if input.type == "jump" and current_time >= input.time:
				_input_queue.remove_at(i)
				return true
		return false
		
	return pressed


# ─── Death & Respawn ────────────────────────────────────────────────────────

## Triggers death sequence.
func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	velocity = Vector2.ZERO
	EventBus.player_died.emit()

	# Death juice: shake + flash + impact particles
	ScreenEffects.shake_camera(12.0, 0.3)
	ScreenEffects.flash_screen(Color.RED, 0.2)
	ParticleFactory.impact(global_position, Color.RED, 20)
	ScreenEffects.slow_motion(0.3, 0.3)

	# Play death animation via animator (if exists)
	var animator := get_node_or_null("AnimatedSprite2D")
	if animator and animator.sprite_frames and animator.sprite_frames.has_animation("death"):
		animator.play("death")
		await animator.animation_finished

	# Respawn handled by LevelManager
	# _is_dead = false  <-- Removed to prevent loop; respawn() handles this



## Called by LevelManager to respawn at checkpoint.
func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	_is_dead = false
	EventBus.player_respawned.emit(spawn_position)


# ─── Physics Change Effects ─────────────────────────────────────────────────

## Colour lookup for physics state visual feedback.
const STATE_COLORS: Dictionary = {
	"Normal": Color.WHITE,
	"ReverseGravity": Color(0, 1, 1),          # Cyan
	"LowGravity": Color(0.5, 0.5, 1.0),        # Periwinkle
	"HighGravity": Color(1, 0.2, 0.2),          # Red
	"ZeroFriction": Color(0.67, 0.87, 1.0),     # Icy Blue
	"SuperFriction": Color(0.55, 0.27, 0.07),   # Mud Brown
	"BouncyPhysics": Color(1, 0.41, 0.71),      # Hot Pink
	"SlowMotion": Color(0.8, 0.8, 0.8),         # Light Gray
	"FastForward": Color(1.0, 1.0, 0.0),        # Yellow
	"TeleportJump": Color(0.5, 0.0, 0.5),       # Purple
	"DoubleJump": Color(0.0, 1.0, 0.0),         # Green
	"InvertedControls": Color(0.8, 0.0, 0.8),   # Magenta
	"DelayedInput": Color(0.5, 0.5, 0.5),       # Gray
	"RandomDirection": Color(1.0, 0.5, 0.0),    # Orange
	"SizeChange": Color(1.0, 0.8, 0.6),         # Flesh/Peach
	"Underwater": Color(0.0, 0.3, 0.8),         # Deep Blue
	"WindForce": Color(0.8, 0.9, 1.0),          # Windy White
	"PhaseThrough": Color(1.0, 1.0, 1.0, 0.5),  # Transparent White
	"MagnetPlatforms": Color(0.6, 0.6, 0.6),    # Iron/Steel
	"WallWalk": Color(0.4, 0.2, 0.0),           # Spider Brown
}


## Called when physics state changes. Triggers visual + audio feedback.
func _on_physics_changed(state_name: String) -> void:
	var color := STATE_COLORS.get(state_name, Color.WHITE) as Color

	# Camera zoom pulse: briefly zoom in then back
	ScreenEffects.zoom_camera(1.15, 0.1)
	await get_tree().create_timer(0.15).timeout
	ScreenEffects.zoom_camera(1.0, 0.3)

	# Screen flash with state colour
	ScreenEffects.flash_screen(color, 0.2)

	# Particle burst at player position
	if not _is_dead:
		ParticleFactory.physics_change_burst(global_position, color)

	# Play state change SFX
	AudioManager.play_sfx("physics_change")
