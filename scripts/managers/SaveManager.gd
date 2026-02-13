## SaveManager — Persistent Game Data (Autoload Singleton)
##
## Handles all local save/load operations for player settings and
## level progress.  Data is stored as a simple JSON file at
## user://save_game.json.
##
## ── Data Structure ──
## {
##   "version": 1,
##   "settings": {
##     "music_volume": 0.8,
##     "sfx_volume": 1.0,
##     "fullscreen": false
##   },
##   "progress": {
##     "1_1": { "completed": true, "stars": 3, "deaths": 2, "best_time": 45.3 },
##     "1_2": { "completed": true, "stars": 2, "deaths": 8, "best_time": 62.1 },
##     ...
##   }
## }
##
## Usage:
##   SaveManager.save_level_completion(1, 3, 2, 12, 55.5)
##   var data = SaveManager.get_level_data(1, 3)
##   SaveManager.save_game()
extends Node


# ─── Constants ───────────────────────────────────────────────────────────────

## Path to the save file on disk.
const SAVE_PATH: String = "user://save_game.json"

## Current save-file schema version.  Bump this when you add fields
## and provide migration logic in _migrate().
const SAVE_VERSION: int = 1


# ─── Runtime data ────────────────────────────────────────────────────────────

## The full save data dictionary, kept in memory for fast reads.
var _data: Dictionary = {}


# ─── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
	load_game()


# ─── Save / Load ─────────────────────────────────────────────────────────────

## Writes the current in-memory data to disk.
func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[SaveManager] Cannot open save file for writing: %s" % SAVE_PATH)
		return

	var json_string := JSON.stringify(_data, "\t")
	file.store_string(json_string)
	file.close()

	if OS.is_debug_build():
		print("[SaveManager] Game saved to %s" % SAVE_PATH)


## Reads save data from disk into memory.
## If the file doesn't exist (first launch), creates default data.
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		if OS.is_debug_build():
			print("[SaveManager] No save file found — creating defaults.")
		_data = _create_default_data()
		save_game()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("[SaveManager] Cannot open save file for reading: %s" % SAVE_PATH)
		_data = _create_default_data()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_text)
	if parse_result != OK:
		push_error("[SaveManager] JSON parse error on line %d: %s" % [json.get_error_line(), json.get_error_message()])
		_data = _create_default_data()
		return

	_data = json.data
	_migrate()

	if OS.is_debug_build():
		print("[SaveManager] Loaded save (version %s, %d levels tracked)." % [
			str(_data.get("version", "?")),
			_data.get("progress", {}).size()
		])


# ─── Level Progress ─────────────────────────────────────────────────────────

## Records a level completion, keeping only the best results.
## [param world] World number (1-based).
## [param level] Level number (1-based).
## [param stars] Star rating earned this attempt (1–3).
## [param deaths] Number of deaths this attempt.
## [param time] Completion time in seconds.
func save_level_completion(world: int, level: int, stars: int, deaths: int, time: float) -> void:
	var key := _level_key(world, level)
	var progress: Dictionary = _data.get("progress", {})

	var existing: Dictionary = progress.get(key, {})
	var best_stars: int = maxi(existing.get("stars", 0), stars)
	var best_deaths: int = mini(existing.get("deaths", 999999), deaths) if existing.has("deaths") else deaths
	var best_time: float = minf(existing.get("best_time", 999999.0), time) if existing.has("best_time") else time

	progress[key] = {
		"completed": true,
		"stars": best_stars,
		"deaths": best_deaths,
		"best_time": best_time,
	}
	_data["progress"] = progress
	save_game()


## Returns the stored data for a specific level, or an empty dict if none.
## Keys: completed (bool), stars (int), deaths (int), best_time (float).
func get_level_data(world: int, level: int) -> Dictionary:
	var key := _level_key(world, level)
	return _data.get("progress", {}).get(key, {})


## Returns true if the given level has been completed at least once.
func is_level_completed(world: int, level: int) -> bool:
	return get_level_data(world, level).get("completed", false)


## Returns the best star rating for a level (0 if never completed).
func get_level_stars(world: int, level: int) -> int:
	return get_level_data(world, level).get("stars", 0)


## Returns the total number of stars earned across all levels.
func get_total_stars() -> int:
	var total := 0
	for entry in _data.get("progress", {}).values():
		total += entry.get("stars", 0)
	return total


# ─── Settings ────────────────────────────────────────────────────────────────

## Returns the full settings dictionary.
func get_settings() -> Dictionary:
	return _data.get("settings", {})


## Gets a single setting value with a fallback default.
func get_setting(key: String, default_value = null):
	return _data.get("settings", {}).get(key, default_value)


## Updates a single setting and persists to disk.
func set_setting(key: String, value) -> void:
	if not _data.has("settings"):
		_data["settings"] = {}
	_data["settings"][key] = value
	save_game()


# ─── Reset ───────────────────────────────────────────────────────────────────

## Wipes all progress data (keeps settings).
func reset_progress() -> void:
	_data["progress"] = {}
	save_game()
	if OS.is_debug_build():
		print("[SaveManager] Progress reset.")


## Wipes *everything* and recreates defaults.
func reset_all() -> void:
	_data = _create_default_data()
	save_game()
	if OS.is_debug_build():
		print("[SaveManager] Full reset to defaults.")


# ─── Internal Helpers ────────────────────────────────────────────────────────

## Creates the default data structure for a fresh save.
func _create_default_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"settings": {
			"music_volume": 0.8,
			"sfx_volume": 1.0,
			"fullscreen": false,
		},
		"progress": {},
	}


## Generates the dictionary key for a world/level pair.
func _level_key(world: int, level: int) -> String:
	return "%d_%d" % [world, level]


## Handles migrating old save versions to the current schema.
func _migrate() -> void:
	var version: int = _data.get("version", 0)
	if version == SAVE_VERSION:
		return

	# ── Example migration (v0 → v1): ──
	# if version < 1:
	#     _data["settings"]["fullscreen"] = false
	#     _data["version"] = 1

	_data["version"] = SAVE_VERSION
	save_game()
	if OS.is_debug_build():
		print("[SaveManager] Migrated save from v%d → v%d." % [version, SAVE_VERSION])
