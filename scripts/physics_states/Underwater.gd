class_name UnderwaterState
extends PhysicsState

func on_enter() -> void:
	super.on_enter()
	gravity_scale = 0.1
	friction = 0.05
	speed_multiplier = 0.5
	tint_color = Color(0.0, 0.3, 0.8) # Deep Blue

func get_state_name() -> String:
	return "Underwater"
