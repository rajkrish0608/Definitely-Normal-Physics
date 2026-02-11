class_name FastForwardState
extends PhysicsState

func on_enter() -> void:
	super.on_enter()
	Engine.time_scale = 2.0
	AudioManager.play_sfx("powerup")

func on_exit() -> void:
	super.on_exit()
	Engine.time_scale = 1.0

func get_state_name() -> String:
	return "FastForward"
