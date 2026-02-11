## LowGravity — Moon-like Floatiness
##
## Gravity is reduced to 30% of normal, making the player float
## much longer in the air.  Jump height is also boosted by 1.5×
## so the player soars upward.  Great for wide-gap levels.
extends PhysicsState


func _init() -> void:
	gravity_scale = 0.3              # 30% gravity — very floaty
	jump_multiplier = 1.5            # Higher jumps to match the theme
	tint_color = Color("#A0D8F0")    # Light blue overlay


func get_state_name() -> String:
	return "Low Gravity"
