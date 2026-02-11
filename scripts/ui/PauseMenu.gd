## PauseMenu — Overlay Shown When Game is Paused (Control)
##
## Pauses game on ESC, shows Resume/Restart/Settings/Quit buttons.
##
## ── Scene Structure ──
## PauseMenu (Control, initially hidden)
## ├── ColorRect (dimmed background)
## └── CenterContainer
##     └── VBoxContainer
##         ├── ResumeButton
##         ├── RestartButton
##         ├── SettingsButton
##         └── QuitButton
extends Control


func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS  # Respond to input even when paused

	$CenterContainer/VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$CenterContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$CenterContainer/VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			_on_resume_pressed()
		else:
			_pause()


func _pause() -> void:
	show()
	get_tree().paused = true
	AudioManager.play_sfx("menu_open")


func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false
	AudioManager.play_sfx("button_click")


func _on_restart_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_sfx("button_click")
	LevelManager.load_level(LevelManager.current_world, LevelManager.current_level)
	hide()


func _on_settings_pressed() -> void:
	AudioManager.play_sfx("button_click")
	# TODO: Show settings panel overlay


func _on_quit_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_sfx("button_click")
	SceneTransition.fade_to_scene("res://scenes/ui/MainMenu.tscn")
