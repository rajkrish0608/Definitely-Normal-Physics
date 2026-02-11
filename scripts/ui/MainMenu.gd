## MainMenu — Landing Screen UI (Control)
##
## Entry point with Play, Level Select, Settings, and Quit buttons.
##
## ── Scene Structure (create manually in Godot) ──
## MainMenu (Control)
## ├── MarginContainer
## │   └── VBoxContainer
## │       ├── TitleLabel (Label)
## │       ├── PlayButton (Button)
## │       ├── LevelSelectButton (Button)
## │       ├── SettingsButton (Button)
## │       └── QuitButton (Button)
extends Control


func _ready() -> void:
	# Connect button signals (adjust node paths as needed)
	$MarginContainer/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$MarginContainer/VBoxContainer/LevelSelectButton.pressed.connect(_on_level_select_pressed)
	$MarginContainer/VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$MarginContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	AudioManager.play_sfx("button_click")
	
	# Load last played level or start from 1-1
	var last_world := 1
	var last_level := 1
	# TODO: Query SaveManager for last played level
	
	LevelManager.load_level(last_world, last_level)


func _on_level_select_pressed() -> void:
	AudioManager.play_sfx("button_click")
	SceneTransition.fade_to_scene("res://scenes/ui/LevelSelectScreen.tscn")


func _on_settings_pressed() -> void:
	AudioManager.play_sfx("button_click")
	# Show settings panel (create as separate scene or overlay)
	var settings := load("res://scenes/ui/SettingsPanel.tscn").instantiate()
	add_child(settings)


func _on_quit_pressed() -> void:
	AudioManager.play_sfx("button_click")
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
