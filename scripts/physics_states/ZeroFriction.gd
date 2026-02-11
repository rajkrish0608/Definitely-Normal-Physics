## ZeroFriction — Pure Ice Physics
##
## Friction is removed entirely.  The player slides continuously
## and can't stop on a dime.  Movement feels slippery, like
## skating on a frozen lake.  An icy blue tint and sparkle
## particles sell the effect.
extends PhysicsState


func _init() -> void:
	friction = 0.0                   # No friction — perpetual sliding
	tint_color = Color("#B0E8FF")    # Icy blue overlay
	particle_effect = "ice_sparkle"  # Frost / sparkle particles at feet


func get_state_name() -> String:
	return "Zero Friction"
