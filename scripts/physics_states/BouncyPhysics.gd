## BouncyPhysics — Rubber Ball Mode
##
## The player bounces off the ground like a rubber ball.
## With a bounce factor of 0.8 (returns 80% of impact velocity),
## each landing launches the player back up almost as high.
## A playful pink tint and sparkle particles complete the look.
extends PhysicsState


func _init() -> void:
	bounce = 0.8                        # 80% velocity preserved on bounce
	tint_color = Color("#FFB0FF")       # Pink overlay
	particle_effect = "bounce_sparkle"  # Sparkle burst on each bounce


func get_state_name() -> String:
	return "Bouncy"
