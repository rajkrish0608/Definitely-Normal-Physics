## SuperFriction — Instant Stop, Hard to Move
##
## Maximum friction makes the player decelerate instantly.
## Combined with a 0.7× speed cap, movement feels sluggish
## and stuck, like walking through mud.  A brown earthy tint
## reinforces the theme.
extends PhysicsState


func _init() -> void:
	friction = 1.0                   # Maximum friction — instant stop
	speed_multiplier = 0.7           # 70% max speed — sluggish
	tint_color = Color("#8B7355")    # Brown / earthy overlay


func get_state_name() -> String:
	return "Super Friction"
