## ReverseGravity — Gravity Pulls Upward
##
## The player falls toward the ceiling instead of the floor.
## Platforms above become the new ground.  The screen gets a
## cool cyan tint to signal the change.
extends PhysicsState


func _init() -> void:
	gravity_direction = Vector2.UP   # Gravity pulls upward
	tint_color = Color("#A0D8F0")    # Light cyan overlay
	sound_effect = "physics_reverse" # Whoosh sound on activation


func on_enter() -> void:
	# Sound is handled by PhysicsManager reading sound_effect,
	# but we could add extra logic here (e.g., flip the player sprite).
	pass


func get_state_name() -> String:
	return "Reverse Gravity"
