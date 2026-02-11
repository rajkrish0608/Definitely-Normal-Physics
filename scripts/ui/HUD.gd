## HUD — In-Game Overlay (CanvasLayer)
##
## Shows level name, death count, and timer during gameplay.
##
## ── Scene Structure ──
## HUD (CanvasLayer)
## ├── LevelLabel (Label) — Top-left
## ├── DeathLabel (Label) — Top-right
## ├── TimerLabel (Label) — Bottom-right
## └── PauseButton (Button) — Top-right corner
extends CanvasLayer


@onready var level_label := $LevelLabel as Label
@onready var death_label := $DeathLabel as Label
@onready var timer_label := $TimerLabel as Label


func _ready() -> void:
	EventBus.level_loaded.connect(_on_level_loaded)
	EventBus.death_count_updated.connect(_on_death_count_updated)


func _process(_delta: float) -> void:
	# Update timer display
	if timer_label and LevelManager.player:
		var time := LevelManager.level_timer
		var minutes := int(time) / 60
		var seconds := int(time) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]


func _on_level_loaded(world: int, level: int) -> void:
	if level_label:
		level_label.text = "World %d-%d" % [world, level]


func _on_death_count_updated(count: int) -> void:
	if death_label:
		death_label.text = "Deaths: %d" % count
		# Animated bounce on update
		var tween := create_tween()
		tween.tween_property(death_label, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(death_label, "scale", Vector2.ONE, 0.1)
