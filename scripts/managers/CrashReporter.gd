extends Node

## CrashReporter — Automated Crash & Error Logging (Autoload Singleton)
##
## Captures unhandled errors and critical warnings, logs them with context
## (level, physics state, player position), and writes to a local crash log.
## Useful for post-launch monitoring (Phase 6).

const CRASH_LOG_PATH := "user://crash_reports.json"
const MAX_REPORTS := 100

var _reports: Array[Dictionary] = []

func _ready() -> void:
	# Load existing reports
	_load_reports()
	
	# Log session start
	_log_event("session_start", "Game launched")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_log_event("session_end", "Game closed normally")
		_save_reports()

## Log a crash or error event with full context.
func report_crash(error_message: String, error_source: String = "") -> void:
	var context := _get_game_context()
	
	var report := {
		"timestamp": Time.get_datetime_string_from_system(),
		"type": "crash",
		"message": error_message,
		"source": error_source,
		"context": context,
		"device": _get_device_info()
	}
	
	_reports.append(report)
	_save_reports()
	
	push_error("[CrashReporter] Crash logged: %s" % error_message)

## Log a warning that could indicate problems.
func report_warning(warning_message: String) -> void:
	_log_event("warning", warning_message)

## Get all crash reports for review.
func get_reports() -> Array[Dictionary]:
	return _reports

## Get crash count since last clear.
func get_crash_count() -> int:
	var count := 0
	for report in _reports:
		if report.get("type", "") == "crash":
			count += 1
	return count

## Clear all reports (after reviewing).
func clear_reports() -> void:
	_reports.clear()
	_save_reports()

## Generate a summary string for display.
func get_summary() -> String:
	var crashes := 0
	var warnings := 0
	var sessions := 0
	
	for report in _reports:
		match report.get("type", ""):
			"crash": crashes += 1
			"warning": warnings += 1
			"session_start": sessions += 1
	
	return "Sessions: %d | Crashes: %d | Warnings: %d | Rate: %.1f%%" % [
		sessions,
		crashes,
		warnings,
		(float(crashes) / max(sessions, 1)) * 100.0
	]


# ─── Internal ───────────────────────────────────────────────────────────────

func _log_event(type: String, message: String) -> void:
	_reports.append({
		"timestamp": Time.get_datetime_string_from_system(),
		"type": type,
		"message": message,
		"context": _get_game_context()
	})
	
	# Cap reports to avoid unbounded growth
	while _reports.size() > MAX_REPORTS:
		_reports.pop_front()

func _get_game_context() -> Dictionary:
	var context := {}
	
	if PhysicsManager and PhysicsManager.current_state:
		context["physics_state"] = PhysicsManager.get_current_state_name()
	
	if LevelManager:
		context["world"] = LevelManager.current_world
		context["level"] = LevelManager.current_level
		context["deaths"] = LevelManager.death_count
		context["timer"] = LevelManager.level_timer
	
	if LevelManager and LevelManager.player:
		context["player_position"] = {
			"x": LevelManager.player.global_position.x,
			"y": LevelManager.player.global_position.y
		}
	
	return context

func _get_device_info() -> Dictionary:
	return {
		"os": OS.get_name(),
		"model": OS.get_model_name(),
		"locale": OS.get_locale(),
		"memory_mb": OS.get_static_memory_usage() / (1024 * 1024),
		"gpu": RenderingServer.get_video_adapter_name()
	}

func _save_reports() -> void:
	var file := FileAccess.open(CRASH_LOG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_reports, "\t"))
		file.close()

func _load_reports() -> void:
	if not FileAccess.file_exists(CRASH_LOG_PATH):
		return
	
	var file := FileAccess.open(CRASH_LOG_PATH, FileAccess.READ)
	if not file:
		return
	
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		if typeof(json.data) == TYPE_ARRAY:
			for item in json.data:
				_reports.append(item)
	
	file.close()
