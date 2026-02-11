## LevelManager — Level Progression & Checkpoints (Autoload Singleton)
##
## Tracks current level, deaths, time, checkpoints, and handles level
## loading/completion logic with star ratings.
##
## ── Star Rating Rules ──
## - 3 stars: ≤ 5 deaths
## - 2 stars: ≤ 10 deaths
## - 1 star: Completed
extends Node


# ─── Current Level State ────────────────────────────────────────────────────

## Active world number (1-based).
var current_world: int = 1

## Active level number within the world (1-based).
var current_level: int = 1

## Deaths in the current level attempt.
var death_count: int = 0

## Elapsed time since level start (seconds).
var level_timer: float = 0.0

## Position where the player will respawn after death.
var checkpoint_position: Vector2 = Vector2.ZERO

## Reference to the player node (set automatically on level load).
var player: CharacterBody2D = null


# ─── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)


func _process(delta: float) -> void:
	if player and not player._is_dead:
		level_timer += delta


# ─── Constants ──────────────────────────────────────────────────────────────

const LEVELS_PER_WORLD: int = 8
const TOTAL_WORLDS: int = 3


# ─── Level Loading ──────────────────────────────────────────────────────────

## Loads and transitions to a specific level.
## Tries .tscn scene first, then falls back to JSON via LevelLoader.
## [param world] World number (1-based).
## [param level] Level number within that world (1-based).
func load_level(world: int, level: int) -> void:
	current_world = world
	current_level = level

	# Save as last played
	SaveManager.set_setting("last_played", {"world": world, "level": level})

	# Try .tscn scene first
	var scene_path := "res://levels/world_%02d/level_%02d.tscn" % [world, level]
	if ResourceLoader.exists(scene_path):
		SceneTransition.fade_to_scene(scene_path, 0.5)
		await SceneTransition.transition_finished
		on_level_start()
		return

	# Fall back to JSON
	var json_path := "res://levels/json/world_%02d_level_%02d.json" % [world, level]
	if FileAccess.file_exists(json_path):
		var level_node := LevelLoader.load_level(json_path)
		if level_node:
			get_tree().current_scene.queue_free()
			get_tree().root.add_child(level_node)
			get_tree().current_scene = level_node
			on_level_start()
			return

	push_error("[LevelManager] Level not found: world %d, level %d" % [world, level])


## Loads the next level in sequence, or returns to level select if at the end.
func load_next_level() -> void:
	var next_level := current_level + 1
	var next_world := current_world
	
	if next_level > LEVELS_PER_WORLD:
		next_level = 1
		next_world += 1
	
	if next_world > TOTAL_WORLDS:
		# All levels complete — return to level select
		SceneTransition.fade_to_scene("res://scenes/ui/LevelSelectScreen.tscn", 0.5)
		return
	
	load_level(next_world, next_level)


## Called after a new level scene finishes loading.
## Resets counters, finds player, sets checkpoint.
func on_level_start() -> void:
	death_count = 0
	level_timer = 0.0

	# Find player in the new scene
	player = _find_player()
	if player:
		checkpoint_position = player.global_position
	else:
		push_warning("[LevelManager] No player found in level scene.")

	# Reset physics to normal
	PhysicsManager.set_state("Normal", true)

	EventBus.level_loaded.emit(current_world, current_level)


# ─── Death & Respawn ────────────────────────────────────────────────────────

## Called when the player dies.
func _on_player_died() -> void:
	death_count += 1
	EventBus.death_count_updated.emit(death_count)

	# Wait a moment for death animation
	await get_tree().create_timer(0.5).timeout

	respawn_player()


## Respawns the player at the last checkpoint.
func respawn_player() -> void:
	if not player:
		push_error("[LevelManager] Cannot respawn: player reference lost.")
		return

	player.respawn(checkpoint_position)


# ─── Checkpoints ────────────────────────────────────────────────────────────

## Saves a new checkpoint position.
## Call this when the player touches a checkpoint flag Area2D.
func save_checkpoint(position: Vector2) -> void:
	checkpoint_position = position
	EventBus.checkpoint_reached.emit(position)


# ─── Level Completion ───────────────────────────────────────────────────────

## Called when the player reaches the exit.
func on_level_complete() -> void:
	var stars := calculate_stars(death_count)
	var time := level_timer

	# Save to persistent storage
	SaveManager.save_level_completion(current_world, current_level, stars, death_count, time)

	EventBus.level_complete.emit(current_world, current_level)

	# Show completion screen (handled by LevelCompleteScreen.gd listening to signal)


## Calculates star rating based on deaths.
func calculate_stars(deaths: int) -> int:
	if deaths <= 5:
		return 3
	elif deaths <= 10:
		return 2
	else:
		return 1


# ─── Helpers ────────────────────────────────────────────────────────────────

## Searches the scene tree for a CharacterBody2D with PlayerController.gd.
func _find_player() -> CharacterBody2D:
	var root := get_tree().current_scene
	return _find_player_recursive(root)


func _find_player_recursive(node: Node) -> CharacterBody2D:
	if node is CharacterBody2D and node.get_script() == preload("res://scripts/player/PlayerController.gd"):
		return node
	for child in node.get_children():
		var found := _find_player_recursive(child)
		if found:
			return found
	return null
