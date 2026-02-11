extends Node

## LevelHotloader — Rapid Iteration Tool
##
## Watches for input (R key) to reload the current level instantly.
## Only active in debug builds.

func _process(delta: float) -> void:
	if not OS.is_debug_build():
		return
		
	if Input.is_key_pressed(KEY_R):
		LevelManager.reload_level()
		print("[LevelHotloader] Reloading current level...")
