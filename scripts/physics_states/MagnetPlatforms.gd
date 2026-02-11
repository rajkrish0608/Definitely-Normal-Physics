class_name MagnetPlatformsState
extends PhysicsState

const MAGNET_FORCE: float = 800.0

func update_physics(delta: float, player: CharacterBody2D) -> void:
	super.update_physics(delta, player)
	
	# Find nearest platform (StaticBody2D in group "Magnetic")
	var nearest: Node2D = null
	var min_dist: float = 300.0 # Range
	
	for node in player.get_tree().get_nodes_in_group("Magnetic"):
		var dist = player.global_position.distance_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = node
			
	if nearest:
		var dir = (nearest.global_position - player.global_position).normalized()
		player.velocity += dir * MAGNET_FORCE * delta

func get_state_name() -> String:
	return "MagnetPlatforms"
