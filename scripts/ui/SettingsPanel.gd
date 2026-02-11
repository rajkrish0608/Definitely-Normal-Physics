## SettingsPanel — Audio & Display Configuration (Control)
##
## Sliders for music/SFX volume, fullscreen toggle.
##
## ── Scene Structure ──
## SettingsPanel (Control)
## └── PanelContainer
##     └── VBoxContainer
##         ├── TitleLabel ("Settings")
##         ├── MusicLabel + MusicSlider (HSlider)
##         ├── SFXLabel + SFXSlider (HSlider)
##         ├── FullscreenCheckbox (CheckBox)
##         └── BackButton
extends Control


@onready var music_slider := $PanelContainer/VBoxContainer/MusicSlider as HSlider
@onready var sfx_slider := $PanelContainer/VBoxContainer/SFXSlider as HSlider
@onready var fullscreen_check := $PanelContainer/VBoxContainer/FullscreenCheckbox as CheckBox
@onready var back_button := $PanelContainer/VBoxContainer/BackButton as Button


func _ready() -> void:
	# Load current settings
	music_slider.value = SaveManager.get_setting("music_volume", 0.8)
	sfx_slider.value = SaveManager.get_setting("sfx_volume", 1.0)
	fullscreen_check.button_pressed = SaveManager.get_setting("fullscreen", false)

	# Connect signals
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_on_back_pressed)


func _on_music_changed(value: float) -> void:
	AudioManager.set_music_volume(value)
	SaveManager.set_setting("music_volume", value)


func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	SaveManager.set_setting("sfx_volume", value)
	AudioManager.play_sfx("button_click", value)  # Preview


func _on_fullscreen_toggled(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	SaveManager.set_setting("fullscreen", enabled)


func _on_back_pressed() -> void:
	AudioManager.play_sfx("button_click")
	queue_free()  # Close panel
