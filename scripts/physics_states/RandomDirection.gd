class_name RandomDirectionState
extends PhysicsState

var _timer: float = 0.0
const INTERVAL: float = 2.0

func on_enter() -> void:
	super.on_enter()
	_randomize_gravity()

func update_physics(delta: float, player: CharacterBody2D) -> void:
	super.update_physics(delta, player)
	
	_timer += delta
	if _timer >= INTERVAL:
		_timer = 0.0
		_randomize_gravity()
		AudioManager.play_sfx("physics_change")
		ScreenEffects.shake_camera(2.0, 0.1)

func _randomize_gravity() -> void:
	# Random cardinal direction
	var dirs := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	gravity_direction = dirs.pick_random()
	
	# Update player rotation to match (optional, but helps orientation)
	EventBus.physics_changed.emit("RandomDirection")

func get_state_name() -> String:
	return "RandomDirection"
