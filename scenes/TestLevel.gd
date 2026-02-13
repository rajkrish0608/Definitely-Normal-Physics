## TestLevel — Quick test scene for development
extends Node2D


func _ready() -> void:
	# Load first level from JSON
	var level_scene: Node2D = LevelLoader.load_level("res://levels/json/world_01_level_01.json")
	if level_scene:
		add_child(level_scene)
		
		# Create simple player for testing (placeholder until Player.tscn is ready)
		var player: CharacterBody2D = _create_test_player()
		var spawn: Node = level_scene.get_node_or_null("PlayerSpawn")
		if spawn:
			player.global_position = spawn.global_position
		add_child(player)
		
		# Add camera to player
		var cam: Camera2D = Camera2D.new()
		cam.enabled = true
		player.add_child(cam)


func _create_test_player() -> CharacterBody2D:
	var player: CharacterBody2D = CharacterBody2D.new()
	player.name = "Player"
	
	# Attach controller script
	var script: Script = load("res://scripts/player/PlayerController.gd")
	player.set_script(script)
	
	# Add collision shape
	var collision: CollisionShape2D = CollisionShape2D.new()
	var capsule: CapsuleShape2D = CapsuleShape2D.new()
	capsule.radius = 8
	capsule.height = 32
	collision.shape = capsule
	player.add_child(collision)
	
	# Add simple visual (colored rectangle)
	var rect: ColorRect = ColorRect.new()
	rect.color = Color(0, 0.5, 1, 1)  # Blue player
	rect.size = Vector2(16, 32)
	rect.position = Vector2(-8, -16)
	player.add_child(rect)
	
	# Set collision layers
	player.collision_layer = 0b01  # Layer 1 (Player)
	player.collision_mask = 0b10   # Layer 2 (World)
	
	return player
