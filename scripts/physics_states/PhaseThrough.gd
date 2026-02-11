class_name PhaseThroughState
extends PhysicsState

# Walls collision layer usually 2 (bit 1)
const WALL_LAYER_BIT = 2

func update_physics(delta: float, player: CharacterBody2D) -> void:
	super.update_physics(delta, player)
	
	# Disable collision with "Phaseable" walls (would need specific layer setup)
	# For prototype, let's say it disables Layer 2 (World) collision
	player.set_collision_mask_value(WALL_LAYER_BIT, false)
	player.modulate.a = 0.5 # Ghostly look

func on_exit() -> void:
	# We can't guarantee access to player here to reset.
	# Best approach: PlayerController resets collision mask in its update if state is NOT PhaseThrough
	pass 

func get_state_name() -> String:
	return "PhaseThrough"
