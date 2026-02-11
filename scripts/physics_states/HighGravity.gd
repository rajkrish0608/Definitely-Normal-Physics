## HighGravity — Heavy, Oppressive Pull
##
## Gravity is 2.5× stronger than normal.  The player falls fast
## and can barely jump.  Requires careful, precise platforming.
## A deep red tint warns that things just got serious.
extends PhysicsState


func _init() -> void:
	gravity_scale = 2.5              # 2.5× normal gravity — very heavy
	jump_multiplier = 0.6            # Weaker jumps — can't escape the pull
	tint_color = Color("#E06060")    # Deep red overlay


func get_state_name() -> String:
	return "High Gravity"
