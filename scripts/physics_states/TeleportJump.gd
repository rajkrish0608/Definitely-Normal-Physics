class_name TeleportJumpState
extends PhysicsState

const TELEPORT_DISTANCE: float = 150.0

func handle_jump(player: CharacterBody2D, velocity: Vector2, jump_velocity: float) -> Vector2:
	# Teleport forward/up instead of normal jump physics
	var direction := Vector2.UP.rotated(player.rotation)
	
	# Determine forward direction from input or velocity
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		direction = (Vector2.UP + Vector2(input_dir, 0)).normalized()
	
	# Raycast to prevent clipping into walls
	var space := player.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(player.global_position, player.global_position + direction * TELEPORT_DISTANCE)
	query.collision_mask = player.collision_mask # Match player layers
	
	var result := space.intersect_ray(query)
	var target_pos := player.global_position + direction * TELEPORT_DISTANCE
	
	if result:
		target_pos = result.position - direction * 10.0 # Stop just before wall
		
	# Perform teleport
	player.global_position = target_pos
	AudioManager.play_sfx("teleport")
	
	# Reset vertical velocity to prevent gravity acumulation during teleport
	return Vector2(velocity.x, 0.0)

func get_state_name() -> String:
	return "TeleportJump"
