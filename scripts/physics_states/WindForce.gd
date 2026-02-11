class_name WindForceState
extends PhysicsState

var wind_force: Vector2 = Vector2(200, 0) # Blow right

func update_physics(delta: float, player: CharacterBody2D) -> void:
	super.update_physics(delta, player)
	
	# Apply constant wind force
	player.velocity += wind_force * delta

func get_state_name() -> String:
	return "WindForce"
