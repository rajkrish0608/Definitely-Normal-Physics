## HUD — In-Game Overlay (CanvasLayer)
##
## Shows level name, death count, timer, and physics state during gameplay.
##
## ── Scene Structure ──
## HUD (CanvasLayer)
## ├── LevelLabel (Label) — Top-left
## ├── DeathLabel (Label) — Top-right
## ├── TimerLabel (Label) — Bottom-right
## ├── PhysicsStateLabel (Label) — Bottom-left
## └── PauseButton (Button) — Top-right corner
extends CanvasLayer


@onready var level_label := $LevelLabel as Label
@onready var death_label := $DeathLabel as Label
@onready var timer_label := $TimerLabel as Label
@onready var physics_label := get_node_or_null("PhysicsStateLabel") as Label

## Colour lookup matching PlayerController for consistency.
const STATE_DISPLAY: Dictionary = {
	"Normal": {"label": "NORMAL", "color": Color.WHITE},
	"ReverseGravity": {"label": "⬆️ REVERSE", "color": Color(0, 1, 1)},
	"LowGravity": {"label": "🪶 LOW-G", "color": Color(0.5, 0.5, 1.0)},
	"HighGravity": {"label": "🏋️ HIGH-G", "color": Color(1, 0.2, 0.2)},
	"ZeroFriction": {"label": "🧊 ICE", "color": Color(0.67, 0.87, 1.0)},
	"SuperFriction": {"label": "🫠 MUD", "color": Color(0.55, 0.27, 0.07)},
	"BouncyPhysics": {"label": "🦘 BOUNCE", "color": Color(1, 0.41, 0.71)},
}


func _ready() -> void:
	EventBus.level_loaded.connect(_on_level_loaded)
	EventBus.death_count_updated.connect(_on_death_count_updated)
	EventBus.physics_changed.connect(_on_physics_changed)


func _process(_delta: float) -> void:
	# Update timer display
	if timer_label and LevelManager.player:
		var time := LevelManager.level_timer
		var minutes := int(time) / 60
		var seconds := int(time) % 60
		var ms := int(fmod(time, 1.0) * 100)
		timer_label.text = "%02d:%02d.%02d" % [minutes, seconds, ms]


func _on_level_loaded(world: int, level: int) -> void:
	if level_label:
		level_label.text = "Experiment %d-%d" % [world, level]


func _on_death_count_updated(count: int) -> void:
	if death_label:
		death_label.text = "Failures: %d" % count
		# Animated bounce on update
		var tween := create_tween()
		tween.tween_property(death_label, "scale", Vector2(1.3, 1.3), 0.08)
		tween.tween_property(death_label, "scale", Vector2.ONE, 0.12).set_ease(Tween.EASE_OUT)


func _on_physics_changed(state_name: String) -> void:
	if not physics_label:
		return

	var display := STATE_DISPLAY.get(state_name, {"label": state_name, "color": Color.WHITE})
	physics_label.text = display.label

	# Animate colour transition
	var tween := create_tween()
	tween.tween_property(physics_label, "modulate", display.color, 0.2)

	# Pop-in animation
	physics_label.scale = Vector2(1.4, 1.4)
	tween.parallel().tween_property(physics_label, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
