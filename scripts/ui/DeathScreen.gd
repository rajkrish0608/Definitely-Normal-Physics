## DeathScreen — Quick Death Notification (Control)
##
## Shows "Death #X" message briefly, then auto-hides.
## Keeps deaths fast and non-intrusive.
##
## ── Scene Structure ──
## DeathScreen (Control, initially hidden)
## └── CenterContainer
##     └── VBoxContainer
##         ├── DeathMessageLabel
##         └── FunnyQuoteLabel
extends Control


## Funny death messages to rotate through.
const DEATH_MESSAGES: Array[String] = [
	"Oops!",
	"Not quite...",
	"Physics are hard!",
	"Try again!",
	"Definitely normal!",
	"That wasn't supposed to happen...",
	"Gravity wins again!",
]


func _ready() -> void:
	hide()
	EventBus.player_died.connect(_on_player_died)


func _on_player_died() -> void:
	show()
	
	var death_label := $CenterContainer/VBoxContainer/DeathMessageLabel as Label
	var quote_label := $CenterContainer/VBoxContainer/FunnyQuoteLabel as Label

	if death_label:
		death_label.text = "Death #%d" % LevelManager.death_count

	if quote_label:
		quote_label.text = DEATH_MESSAGES.pick_random()

	# Auto-hide after 0.5s
	await get_tree().create_timer(0.5).timeout
	hide()
