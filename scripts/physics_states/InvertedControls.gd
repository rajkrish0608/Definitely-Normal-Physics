class_name InvertedControlsState
extends PhysicsState

func on_enter() -> void:
	super.on_enter()
	controls_reversed = true
	tint_color = Color(0.8, 0.0, 0.8) # Purple

func on_exit() -> void:
	super.on_exit()
	controls_reversed = false

func get_state_name() -> String:
	return "InvertedControls"
