extends Node

## LevelHotloader — Rapid Iteration Tool
##
## Watches for input (R key) to reload the current level instantly.
## Only active in debug builds.

func _process(_delta: float) -> void:
	if not OS.is_debug_build():
		return
		
	if Input.is_action_just_pressed("ui_cancel") and Input.is_key_pressed(KEY_R):
		LevelManager.reload_current_level()
		print("[LevelHotloader] Reloading current level...")
