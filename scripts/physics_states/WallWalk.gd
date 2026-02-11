class_name WallWalkState
extends PhysicsState

func on_enter() -> void:
	super.on_enter()
	# This one is complex. Requires changing player's "up_direction" based on raycasts.
	# Simplified version: Stick to walls if touching.
	gravity_scale = 0.0 # Manual gravity

func update_physics(delta: float, player: CharacterBody2D) -> void:
	# Raycast 4 directions
	var space = player.get_world_2d().direct_space_state
	var down = space.intersect_ray(PhysicsRayQueryParameters2D.create(player.global_position, player.global_position + Vector2(0, 30)))
	var left = space.intersect_ray(PhysicsRayQueryParameters2D.create(player.global_position, player.global_position + Vector2(-30, 0)))
	var right = space.intersect_ray(PhysicsRayQueryParameters2D.create(player.global_position, player.global_position + Vector2(30, 0)))
	var up = space.intersect_ray(PhysicsRayQueryParameters2D.create(player.global_position, player.global_position + Vector2(0, -30)))
	
	var target_up = Vector2.UP
	
	if down: target_up = Vector2.UP
	elif left: target_up = Vector2.RIGHT
	elif right: target_up = Vector2.LEFT
	elif up: target_up = Vector2.DOWN
	
	player.up_direction = target_up
	player.rotation = target_up.angle() + PI/2
	
	# Apply "gravity" towards the wall
	player.velocity -= target_up * 500.0 * delta

func get_state_name() -> String:
	return "WallWalk"
