class_name DoubleJumpState
extends PhysicsState

var _can_double_jump: bool = false

func update_physics(delta: float, player: CharacterBody2D) -> void:
	super.update_physics(delta, player)
	
	if player.is_on_floor():
		_can_double_jump = true

func handle_jump(player: CharacterBody2D, velocity: Vector2, jump_velocity: float) -> Vector2:
	if player.is_on_floor():
		AudioManager.play_sfx("jump")
		return super.handle_jump(player, velocity, jump_velocity)
	elif _can_double_jump:
		_can_double_jump = false
		AudioManager.play_sfx("jump") # Different sound ideally
		ParticleFactory.impact(player.global_position, Color.CYAN, 5) # Visual feedback
		return super.handle_jump(player, velocity, jump_velocity)
		
	return velocity
		
	return velocity

func get_state_name() -> String:
	return "DoubleJump"
