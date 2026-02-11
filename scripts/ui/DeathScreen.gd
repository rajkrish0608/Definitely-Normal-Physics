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
	"Have you tried not dying?",
	"Gravity 1, You 0.",
	"Working as intended.",
	"Physics checks out.",
	"That looked painful. Do it again.",
	"Skill issue detected.",
	"Refunding your momentum...",
	"Did you forget up is down?",
	"Friction is a privilege, not a right.",
	"Error: Player object destroyed.",
	"Maybe try jumping?",
	"Newton is rolling in his grave.",
	"Lag? No, that was you.",
	"Have a participant ribbon.",
	"Resetting simulation..."
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
