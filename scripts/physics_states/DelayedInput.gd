class_name DelayedInputState
extends PhysicsState

func on_enter() -> void:
	super.on_enter()
	input_delay = 0.25 # 250ms delay
	tint_color = Color(0.5, 0.5, 0.5) # Gray

func on_exit() -> void:
	super.on_exit()
	input_delay = 0.0

func get_state_name() -> String:
	return "DelayedInput"
