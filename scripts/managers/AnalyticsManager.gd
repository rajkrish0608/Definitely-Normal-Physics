## AnalyticsManager — Privacy-First Event Tracker (Autoload Singleton)
##
## Tracks gameplay events locally and (optionally) sends them to a backend API.
## All data is anonymous — no PII is collected.
##
## Events are queued in-memory and flushed to disk periodically.
## When an API endpoint is configured, queued events are uploaded in batches.
##
## Usage:
##   AnalyticsManager.track("level_start", {"world": 1, "level": 3})
##   AnalyticsManager.flush()
extends Node


# ─── Configuration ──────────────────────────────────────────────────────────

## Backend API endpoint (empty = local-only mode).
const API_ENDPOINT: String = ""

## Maximum events to hold in memory before auto-flushing to disk.
const MAX_QUEUE_SIZE: int = 50

## Auto-flush interval in seconds.
const FLUSH_INTERVAL: float = 60.0

## Local file path for offline event storage.
const LOCAL_CACHE_PATH: String = "user://analytics_cache.json"


# ─── State ──────────────────────────────────────────────────────────────────

## In-memory event queue.
var _event_queue: Array[Dictionary] = []

## Unique anonymous session ID (regenerated each app launch).
var _session_id: String = ""

## Session start timestamp.
var _session_start: float = 0.0

## Flush timer.
var _flush_timer: float = 0.0

## Whether analytics is enabled (user can opt out).
var analytics_enabled: bool = true


# ─── Lifecycle ──────────────────────────────────────────────────────────────

func _ready() -> void:
	# Generate anonymous session ID (no PII)
	_session_id = _generate_session_id()
	_session_start = Time.get_unix_time_from_system()

	# Load user preference
	analytics_enabled = SaveManager.get_setting("analytics_enabled", true)

	# Connect to game events
	_connect_game_events()

	# Track session start
	track("session_start", {
		"platform": OS.get_name(),
		"locale": OS.get_locale(),
		"version": ProjectSettings.get_setting("application/config/version", "0.1.0"),
	})

	# Load any cached offline events
	_load_cached_events()


func _process(delta: float) -> void:
	if not analytics_enabled:
		return

	_flush_timer += delta
	if _flush_timer >= FLUSH_INTERVAL:
		_flush_timer = 0.0
		flush()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		# Track session end and flush before exit
		var session_duration := Time.get_unix_time_from_system() - _session_start
		track("session_end", {"duration_seconds": session_duration})
		flush()


# ─── Public API ─────────────────────────────────────────────────────────────

## Track a named event with optional properties.
func track(event_name: String, properties: Dictionary = {}) -> void:
	if not analytics_enabled:
		return

	var event := {
		"event": event_name,
		"session_id": _session_id,
		"timestamp": Time.get_unix_time_from_system(),
		"properties": properties,
	}

	_event_queue.append(event)

	if OS.is_debug_build():
		print("[Analytics] %s → %s" % [event_name, str(properties)])

	# Auto-flush if queue is full
	if _event_queue.size() >= MAX_QUEUE_SIZE:
		flush()


## Flush all queued events: save to disk and (if configured) send to API.
func flush() -> void:
	if _event_queue.is_empty():
		return

	# Always save to local cache first
	_save_cached_events()

	# If API is configured, attempt upload
	if API_ENDPOINT != "":
		_upload_events(_event_queue.duplicate())

	_event_queue.clear()


## Enable or disable analytics (persisted to SaveManager).
func set_analytics_enabled(enabled: bool) -> void:
	analytics_enabled = enabled
	SaveManager.set_setting("analytics_enabled", enabled)

	if not enabled:
		# Clear all cached data on opt-out
		_event_queue.clear()
		if FileAccess.file_exists(LOCAL_CACHE_PATH):
			DirAccess.remove_absolute(LOCAL_CACHE_PATH)


## Get a summary of tracked data for the current session (for debug/settings UI).
func get_session_summary() -> Dictionary:
	return {
		"session_id": _session_id,
		"events_queued": _event_queue.size(),
		"session_duration": Time.get_unix_time_from_system() - _session_start,
		"analytics_enabled": analytics_enabled,
	}


# ─── Game Event Listeners ──────────────────────────────────────────────────

func _connect_game_events() -> void:
	EventBus.level_loaded.connect(_on_level_loaded)
	EventBus.level_complete.connect(_on_level_complete)
	EventBus.player_died.connect(_on_player_died)
	EventBus.physics_changed.connect(_on_physics_changed)
	EventBus.checkpoint_reached.connect(_on_checkpoint_reached)
	EventBus.death_count_updated.connect(_on_death_count_updated)


func _on_level_loaded(world: int, level: int) -> void:
	track("level_start", {
		"world": world,
		"level": level,
	})


func _on_level_complete(world: int, level: int) -> void:
	track("level_complete", {
		"world": world,
		"level": level,
		"deaths": LevelManager.death_count,
		"time_seconds": LevelManager.level_timer,
		"stars": LevelManager.calculate_stars(LevelManager.death_count),
	})


func _on_player_died() -> void:
	track("player_death", {
		"world": LevelManager.current_world,
		"level": LevelManager.current_level,
		"death_number": LevelManager.death_count,
	})


func _on_physics_changed(state_name: String) -> void:
	track("physics_change", {
		"state": state_name,
		"world": LevelManager.current_world,
		"level": LevelManager.current_level,
	})


func _on_checkpoint_reached(position: Vector2) -> void:
	track("checkpoint", {
		"world": LevelManager.current_world,
		"level": LevelManager.current_level,
		"position": str(position),
	})


func _on_death_count_updated(count: int) -> void:
	# Only track milestones to avoid noise
	if count in [5, 10, 25, 50, 100]:
		track("death_milestone", {
			"count": count,
			"world": LevelManager.current_world,
			"level": LevelManager.current_level,
		})


# ─── Persistence ────────────────────────────────────────────────────────────

func _save_cached_events() -> void:
	var file := FileAccess.open(LOCAL_CACHE_PATH, FileAccess.WRITE)
	if not file:
		push_warning("[Analytics] Failed to save cache: %s" % FileAccess.get_open_error())
		return

	var data := JSON.stringify(_event_queue, "\t")
	file.store_string(data)
	file.close()


func _load_cached_events() -> void:
	if not FileAccess.file_exists(LOCAL_CACHE_PATH):
		return

	var file := FileAccess.open(LOCAL_CACHE_PATH, FileAccess.READ)
	if not file:
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err == OK and json.data is Array:
		# Prepend cached events (they're older)
		var cached: Array = json.data
		for event in cached:
			_event_queue.insert(0, event)


# ─── Network ────────────────────────────────────────────────────────────────

func _upload_events(events: Array) -> void:
	if API_ENDPOINT == "":
		return

	var http := HTTPRequest.new()
	add_child(http)

	var headers := ["Content-Type: application/json"]
	var body := JSON.stringify({"events": events})

	http.request_completed.connect(func(_result, code, _headers, _body):
		if code == 200 or code == 201:
			# Clear local cache on successful upload
			if FileAccess.file_exists(LOCAL_CACHE_PATH):
				DirAccess.remove_absolute(LOCAL_CACHE_PATH)
		else:
			push_warning("[Analytics] Upload failed (HTTP %d), events cached locally" % code)
		http.queue_free()
	)

	http.request(API_ENDPOINT, headers, HTTPClient.METHOD_POST, body)


# ─── Helpers ────────────────────────────────────────────────────────────────

func _generate_session_id() -> String:
	var bytes := PackedByteArray()
	for i in 16:
		bytes.append(randi() % 256)
	return bytes.hex_encode()
