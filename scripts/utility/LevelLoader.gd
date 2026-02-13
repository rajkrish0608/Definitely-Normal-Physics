## LevelLoader — Dynamic Level Builder from JSON (Static Utility)
##
## Reads JSON level definitions and creates scenes programmatically.
## Useful for rapid prototyping and AI-assisted level generation.
##
## ── JSON Format ──
## {
##   "level_id": "world_01_level_03",
##   "player_spawn": [100, 500],
##   "platforms": [{"position": [x, y], "size": [w, h], "type": "normal"}],
##   "hazards": [{"position": [x, y], "type": "spike"}],
##   "physics_triggers": [{
##     "position": [x, y],
##     "size": [w, h],
##     "state": "LowGravity",
##     "trigger_type": "enter",
##     "delay": 0.0
##   }],
##   "checkpoints": [{"position": [x, y]}],
##   "exit": {"position": [x, y]}
## }
class_name LevelLoader
extends RefCounted


## Dictionary to store pooled nodes by type.
static var _pool: Dictionary = {}


## Loads a level from a JSON file and returns the constructed Node2D scene.
## Returns null if loading fails.
static func load_level(json_path: String) -> Node2D:
	# Clear pool at start of level load to avoid stale references
	_pool.clear()
	
	if not FileAccess.file_exists(json_path):
		push_error("[LevelLoader] JSON file not found: %s" % json_path)
		return null

	var file := FileAccess.open(json_path, FileAccess.READ)
	if not file:
		push_error("[LevelLoader] Cannot open file: %s" % json_path)
		return null

	var json_text: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_text)
	if parse_result != OK:
		push_error("[LevelLoader] JSON parse error: %s" % json.get_error_message())
		return null

	var data: Dictionary = json.data
	return _build_level(data)


## Constructs a level scene from parsed JSON data.
static func _build_level(data: Dictionary) -> Node2D:
	var root := Node2D.new()
	root.name = data.get("level_id", "Level")

	# ── Player Spawn ──
	var spawn_pos := _parse_vec2(data.get("player_spawn", [100, 500]))
	var spawn_marker := Marker2D.new()
	spawn_marker.name = "PlayerSpawn"
	spawn_marker.position = spawn_pos
	root.add_child(spawn_marker)

	# ── Platforms ──
	var platforms_container := Node2D.new()
	platforms_container.name = "Platforms"
	root.add_child(platforms_container)
	for platform_data in data.get("platforms", []):
		var platform := _create_platform(platform_data)
		platforms_container.add_child(platform)

	# ── Hazards ──
	var hazards_container := Node2D.new()
	hazards_container.name = "Hazards"
	root.add_child(hazards_container)
	for hazard_data in data.get("hazards", []):
		var hazard := _create_hazard(hazard_data)
		hazards_container.add_child(hazard)

	# ── Physics Triggers ──
	var triggers_container := Node2D.new()
	triggers_container.name = "PhysicsTriggers"
	root.add_child(triggers_container)
	for trigger_data in data.get("physics_triggers", []):
		var trigger := _create_trigger(trigger_data)
		triggers_container.add_child(trigger)

	# ── Checkpoints ──
	var checkpoints_container := Node2D.new()
	checkpoints_container.name = "Checkpoints"
	root.add_child(checkpoints_container)
	for checkpoint_data in data.get("checkpoints", []):
		var checkpoint := _create_checkpoint(checkpoint_data)
		checkpoints_container.add_child(checkpoint)

	# ── Exit ──
	if data.has("exit"):
		var exit := _create_exit(data["exit"])
		root.add_child(exit)

	return root


## Creates a platform StaticBody2D from JSON data.
static func _create_platform(data: Dictionary) -> StaticBody2D:
	var platform := _get_from_pool("platform") as StaticBody2D
	if not platform:
		platform = StaticBody2D.new()
		var collision := CollisionShape2D.new()
		collision.shape = RectangleShape2D.new()
		platform.add_child(collision)
		var rect := ColorRect.new()
		platform.add_child(rect)

	platform.position = _parse_vec2(data.get("position", [0, 0]))
	platform.collision_layer = 0b10 
	platform.collision_mask = 0

	var size := _parse_vec2(data.get("size", [64, 32]))
	platform.get_child(0).shape.size = size
	platform.get_child(1).size = size
	platform.get_child(1).position = -size / 2.0

	return platform


## Creates a hazard Area2D from JSON data.
static func _create_hazard(data: Dictionary) -> Area2D:
	var hazard := _get_from_pool("hazard") as Area2D
	if not hazard:
		hazard = Area2D.new()
		var collision := CollisionShape2D.new()
		collision.shape = RectangleShape2D.new()
		hazard.add_child(collision)
		var rect := ColorRect.new()
		hazard.add_child(rect)

	hazard.position = _parse_vec2(data.get("position", [0, 0]))
	hazard.collision_layer = 0b1000 # Layer 4 = Hazards
	hazard.collision_mask = 0b01

	var size := Vector2(32, 32)
	hazard.get_child(0).shape.size = size
	hazard.get_child(1).size = size
	hazard.get_child(1).position = -size / 2.0
	hazard.get_child(1).color = Color(1, 0, 0, 0.8)

	return hazard


## Internal helper to get a node from the pool or return null.
static func _get_from_pool(type: String) -> Node:
	if _pool.has(type) and _pool[type].size() > 0:
		return _pool[type].pop_back()
	return null


## Internal helper to return a node to the pool.
static func _return_to_pool(type: String, node: Node) -> void:
	if not _pool.has(type):
		_pool[type] = []
	_pool[type].append(node)


## Creates a physics trigger from JSON data.
static func _create_trigger(data: Dictionary) -> Area2D:
	var trigger := Area2D.new()
	var script := preload("res://scripts/triggers/PhysicsTrigger.gd")
	trigger.set_script(script)

	trigger.position = _parse_vec2(data.get("position", [0, 0]))
	trigger.target_physics_state = data.get("state", "Normal")
	trigger.trigger_type = data.get("trigger_type", "enter")
	trigger.delay = data.get("delay", 0.0)

	var size := _parse_vec2(data.get("size", [64, 64]))
	var shape := RectangleShape2D.new()
	shape.size = size

	var collision := CollisionShape2D.new()
	collision.shape = shape
	trigger.add_child(collision)

	return trigger


## Creates a checkpoint Area2D from JSON data.
static func _create_checkpoint(data: Dictionary) -> Area2D:
	var checkpoint := Area2D.new()
	checkpoint.position = _parse_vec2(data.get("position", [0, 0]))

	var shape := RectangleShape2D.new()
	shape.size = Vector2(32, 64)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	checkpoint.add_child(collision)

	# Connect to LevelManager
	checkpoint.body_entered.connect(
		func(body):
			if body.collision_layer & 0b01:  # Player
				LevelManager.save_checkpoint(checkpoint.global_position)
	)

	return checkpoint


## Creates an exit Area2D from JSON data.
static func _create_exit(data: Dictionary) -> Area2D:
	var exit := Area2D.new()
	exit.name = "Exit"
	exit.position = _parse_vec2(data.get("position", [0, 0]))

	var shape := RectangleShape2D.new()
	shape.size = Vector2(64, 64)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	exit.add_child(collision)

	# Visual (green rectangle)
	var rect := ColorRect.new()
	rect.color = Color(0, 1, 0, 0.8)
	rect.size = Vector2(64, 64)
	rect.position = Vector2(-32, -32)
	exit.add_child(rect)

	# Connect to level completion
	exit.body_entered.connect(
		func(body):
			if body.collision_layer & 0b01:  # Player
				LevelManager.on_level_complete()
	)

	return exit


## Parses a [x, y] array into Vector2.
static func _parse_vec2(arr: Array) -> Vector2:
	if arr.size() >= 2:
		return Vector2(float(arr[0]), float(arr[1]))
	return Vector2.ZERO
