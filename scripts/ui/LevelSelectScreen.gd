## LevelSelectScreen — Grid of Playable Levels (Control)
##
## Shows all levels with star ratings and locked/unlocked states.
##
## ── Scene Structure ──
## LevelSelectScreen (Control)
## └── ScrollContainer
##     └── GridContainer (columns = 4)
##         ├── LevelButton × N (created dynamically)
extends Control


@onready var grid := $ScrollContainer/GridContainer as GridContainer


## Total worlds and levels (configure as needed).
const TOTAL_WORLDS: int = 2
const LEVELS_PER_WORLD: int = 8


func _ready() -> void:
	_populate_levels()


func _populate_levels() -> void:
	# Clear existing buttons
	for child in grid.get_children():
		child.queue_free()

	for world in range(1, TOTAL_WORLDS + 1):
		for level in range(1, LEVELS_PER_WORLD + 1):
			var button := _create_level_button(world, level)
			grid.add_child(button)


func _create_level_button(world: int, level: int) -> Button:
	var button := Button.new()
	button.text = "%d-%d" % [world, level]
	button.custom_minimum_size = Vector2(80, 80)

	# Check if level is unlocked and get star count
	var data := SaveManager.get_level_data(world, level)
	var unlocked := data.get("completed", false) or (world == 1 and level == 1)  # First level always unlocked
	var stars := data.get("stars", 0)

	if not unlocked:
		button.disabled = true
		button.text += "\n🔒"
	elif stars > 0:
		button.text += "\n" + "⭐".repeat(stars)

	button.pressed.connect(func(): _on_level_pressed(world, level))
	return button


func _on_level_pressed(world: int, level: int) -> void:
	AudioManager.play_sfx("button_click")
	LevelManager.load_level(world, level)
