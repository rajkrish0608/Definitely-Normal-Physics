## NormalPhysics — Standard Platformer Physics
##
## The default state.  Everything is set to baseline values so the game
## feels like a "normal" 2D platformer.  This state is active at the
## start of every level and after physics resets.
extends PhysicsState


func _init() -> void:
	# All properties keep their PhysicsState defaults:
	# gravity_scale   = 1.0
	# gravity_direction = Vector2.DOWN
	# friction        = 0.5
	# bounce          = 0.0
	# speed_multiplier = 1.0
	# jump_multiplier  = 1.0
	# controls_reversed = false
	# input_delay     = 0.0
	# tint_color      = Color.WHITE  (no tint)
	# particle_effect = ""
	# sound_effect    = ""
	pass


func get_state_name() -> String:
	return "Normal"
