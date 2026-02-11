## PerformanceMonitor — Runtime Performance Tracking (Debug Tool)
##
## Displays FPS, frame time, draw calls, and memory usage in an overlay.
## Attach to a CanvasLayer in your debug scene or toggle with a hotkey.
##
## Only visible in debug builds. Automatically hides in release.
extends CanvasLayer


# ─── Nodes ──────────────────────────────────────────────────────────────────

var _label: Label = null
var _update_timer: float = 0.0

const UPDATE_INTERVAL: float = 0.25  # seconds between display updates


# ─── Lifecycle ──────────────────────────────────────────────────────────────

func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return

	layer = 100  # always on top

	_label = Label.new()
	_label.position = Vector2(10, 10)
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color.GREEN)
	_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	_label.add_theme_constant_override("shadow_offset_x", 1)
	_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(_label)


func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer < UPDATE_INTERVAL:
		return
	_update_timer = 0.0

	var fps := Engine.get_frames_per_second()
	var frame_ms := delta * 1000.0
	var mem_static := OS.get_static_memory_usage() / (1024.0 * 1024.0)
	var object_count := Performance.get_monitor(Performance.OBJECT_COUNT)
	var node_count := Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var orphan_count := Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)

	var color := Color.GREEN
	if fps < 30:
		color = Color.RED
	elif fps < 55:
		color = Color.YELLOW

	_label.add_theme_color_override("font_color", color)
	_label.text = "FPS: %d (%.1fms)\nMem: %.1f MB\nObjects: %d | Nodes: %d\nOrphans: %d | Draws: %d" % [
		fps, frame_ms, mem_static, object_count, node_count, orphan_count, draw_calls
	]
