extends CanvasLayer

## PostLaunchDashboard — In-Game Analytics Viewer
##
## Shows live analytics data: session stats, level completion rates,
## death hotspots, and crash reports. Toggle with F2.
## Only visible in debug builds.

@onready var panel: Panel = $Panel
@onready var stats_label: RichTextLabel = $Panel/VBox/StatsLabel
@onready var level_stats: RichTextLabel = $Panel/VBox/LevelStats
@onready var crash_label: RichTextLabel = $Panel/VBox/CrashLabel

var _visible := false

func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	
	hide()
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		_visible = not _visible
		visible = _visible
		if _visible:
			_refresh_data()

func _refresh_data() -> void:
	_update_session_stats()
	_update_level_stats()
	_update_crash_stats()

func _update_session_stats() -> void:
	var text := "[b]📊 Session Analytics[/b]\n\n"
	
	# Current session info
	text += "Current World: %d | Level: %d\n" % [LevelManager.current_world, LevelManager.current_level]
	text += "Deaths This Level: %d\n" % LevelManager.death_count
	text += "Level Timer: %.1fs\n" % LevelManager.level_timer
	text += "Physics State: %s\n" % PhysicsManager.get_current_state_name()
	text += "FPS: %d\n" % Engine.get_frames_per_second()
	
	# Analytics status
	text += "\nAnalytics: %s\n" % ("Enabled" if AnalyticsManager.analytics_enabled else "Disabled")
	
	stats_label.text = text

func _update_level_stats() -> void:
	var text := "[b]🏆 Level Completion Data[/b]\n\n"
	
	# Read from save data
	for world in range(1, 4):
		text += "[b]World %d:[/b] " % world
		for level in range(1, 9):
			var key := "w%d_l%d" % [world, level]
			var save_data = SaveManager.get_setting(key)
			
			if save_data and typeof(save_data) == TYPE_DICTIONARY:
				var stars = save_data.get("stars", 0)
				text += "%s " % ("⭐" if stars >= 1 else "○").repeat(1)
			else:
				text += "○ "
		text += "\n"
	
	level_stats.text = text

func _update_crash_stats() -> void:
	var text := "[b]🔥 Crash Reports[/b]\n\n"
	
	text += CrashReporter.get_summary() + "\n\n"
	
	# Show last 5 reports
	var reports = CrashReporter.get_reports()
	var start = max(0, reports.size() - 5)
	
	for i in range(start, reports.size()):
		var r = reports[i]
		text += "[color=gray]%s[/color] [%s] %s\n" % [
			r.get("timestamp", "?"),
			r.get("type", "?").to_upper(),
			r.get("message", "?")
		]
	
	if reports.size() == 0:
		text += "[color=green]No reports. Clean session![/color]"
	
	crash_label.text = text
