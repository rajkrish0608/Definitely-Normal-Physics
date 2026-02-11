class_name SizeChangeState
extends PhysicsState

func on_enter() -> void:
	super.on_enter()
	# Access player via 'owner' if possible, or expect PlayerController to handle visual scale
	# Since PhysicsState is a Resource/Node acting on player, we need to signal the player
	# But update_physics passes the player!
	pass

func update_physics(delta: float, player: CharacterBody2D) -> void:
	super.update_physics(delta, player)
	
	# Smoothly scale up
	if player.scale.x < 2.0:
		var s = player.scale.x + delta * 2.0
		s = min(s, 2.0)
		player.scale = Vector2(s, s)

func on_exit() -> void:
	# We need a way to reset player scale. 
	# Ideally PlayerController checks "if not SizeChangeState: target_scale = 1.0"
	# For now, we rely on the next state to normalize, or we handle it in PlayerController
	# But strictly speaking, on_exit doesn't have reference to player unless we store it.
	pass

func get_state_name() -> String:
	return "SizeChange"
