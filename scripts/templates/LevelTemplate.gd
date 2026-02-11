class_name LevelTemplate
extends Node2D

## Base class for Scene-based levels.
##
## If you prefer using the Editor to build levels instead of JSON,
## inherit from this script (or attach it to your root node).
##
## It auto-registers itself with LevelManager on start.

@export var level_name: String = "Custom Level"
@export var time_limit: float = 300.0

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var exit_area: Area2D = $ExitPoint

func _ready() -> void:
	# 1. Initialize Player
	if LevelManager.player_scene:
		var player = LevelManager.player_scene.instantiate()
		player.global_position = spawn_point.global_position
		add_child(player)
		LevelManager.player = player
	
	# 2. Connect Exit
	if exit_area:
		exit_area.body_entered.connect(_on_exit_entered)
	
	# 3. Notify Manager
	LevelManager.on_level_start()
	
	print("[LevelTemplate] Level '%s' ready." % level_name)

func _on_exit_entered(body: Node2D) -> void:
	if body is CharacterBody2D: # Assuming it's the player
		LevelManager.on_level_complete()
