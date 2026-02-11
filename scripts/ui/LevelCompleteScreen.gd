## LevelCompleteScreen — Victory Celebration UI (Control)
##
## Shows stars earned, stats, and Next/Retry/LevelSelect buttons.
##
## ── Scene Structure ──
## LevelCompleteScreen (Control, initially hidden)
## └── CenterContainer
##     └── VBoxContainer
##         ├── TitleLabel ("Level Complete!")
##         ├── StarsContainer (HBoxContainer with 3 star icons)
##         ├── StatsLabel (deaths, time)
##         ├── NextButton
##         ├── RetryButton
##         └── LevelSelectButton
extends Control


func _ready() -> void:
	hide()
	EventBus.level_complete.connect(_on_level_complete)

	# Set themed copy
	$CenterContainer/VBoxContainer/NextButton.text = "Next Experiment"
	$CenterContainer/VBoxContainer/RetryButton.text = "Retry Simulation"
	$CenterContainer/VBoxContainer/LevelSelectButton.text = "Experiment List"

	$CenterContainer/VBoxContainer/NextButton.pressed.connect(_on_next_pressed)
	$CenterContainer/VBoxContainer/RetryButton.pressed.connect(_on_retry_pressed)
	$CenterContainer/VBoxContainer/LevelSelectButton.pressed.connect(_on_level_select_pressed)


func _on_level_complete(world: int, level: int) -> void:
	show()
	get_tree().paused = true

	var stars := LevelManager.calculate_stars(LevelManager.death_count)
	_display_stars(stars)

	# Update title based on performance
	var title_label := $CenterContainer/VBoxContainer/TitleLabel as Label
	if title_label:
		if stars == 3:
			title_label.text = "Simulation Perfect!"
		elif stars == 2:
			title_label.text = "Simulation Successful"
		else:
			title_label.text = "Simulation... Complete."

	var stats_label := $CenterContainer/VBoxContainer/StatsLabel as Label
	if stats_label:
		var time := LevelManager.level_timer
		stats_label.text = "Deaths: %d | Time: %.1fs" % [LevelManager.death_count, time]

	AudioManager.play_sfx("level_complete")


func _display_stars(count: int) -> void:
	var stars_container := $CenterContainer/VBoxContainer/StarsContainer
	if not stars_container:
		return

	# Animate each star appearing
	for i in stars_container.get_child_count():
		var star := stars_container.get_child(i)
		star.modulate.a = 0 if i >= count else 1
		if i < count:
			var tween := create_tween()
			tween.tween_property(star, "modulate:a", 1.0, 0.3).set_delay(i * 0.2)
			tween.tween_property(star, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property(star, "scale", Vector2.ONE, 0.1)


func _on_next_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_sfx("button_click")
	LevelManager.load_next_level()
	hide()


func _on_retry_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_sfx("button_click")
	LevelManager.load_level(LevelManager.current_world, LevelManager.current_level)
	hide()


func _on_level_select_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_sfx("button_click")
	SceneTransition.fade_to_scene("res://scenes/ui/LevelSelectScreen.tscn")
