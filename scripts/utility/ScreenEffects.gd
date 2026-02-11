## ScreenEffects — Visual Juice Controller (Autoload Singleton)
##
## Provides camera shake, screen flash, colour tint, slow-motion,
## and camera zoom.  Multiple effects can run simultaneously because
## each one uses its own Tween.
##
## The singleton creates its own CanvasLayer + ColorRect for overlays
## so nothing needs to be placed in individual scenes.
##
## Usage:
##   ScreenEffects.shake_camera(8.0, 0.3)
##   ScreenEffects.flash_screen(Color.RED, 0.15)
##   ScreenEffects.set_screen_tint(Color(0.6, 0.85, 1.0), 0.5)
##   ScreenEffects.slow_motion(0.3, 1.0)
##   ScreenEffects.zoom_camera(1.5, 0.4)
extends Node


# ─── Internal state ──────────────────────────────────────────────────────────

## Reference to the current scene's Camera2D.  Set automatically via
## `_find_camera()` or manually with `register_camera()`.
var _camera: Camera2D = null

## Overlay rectangle used for flash / tint effects.
var _overlay: ColorRect = null

## CanvasModulate node used for full-scene tint colouring.
var _canvas_modulate: CanvasModulate = null

## Active tweens keyed by effect name so we can kill & restart them.
var _tweens: Dictionary = {}

## Original camera offset before shaking.
var _camera_original_offset: Vector2 = Vector2.ZERO


# ─── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
	# ---------- Overlay layer (always on top) ----------
	var layer := CanvasLayer.new()
	layer.layer = 100  # Above everything
	add_child(layer)

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)  # Fully transparent
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Full-screen: anchored to the viewport
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_overlay)

	# ---------- CanvasModulate for tint ----------
	_canvas_modulate = CanvasModulate.new()
	_canvas_modulate.color = Color.WHITE
	add_child(_canvas_modulate)


## Register (or re-register) the active game camera.
## Call this from your level / player setup when the camera is ready.
func register_camera(camera: Camera2D) -> void:
	_camera = camera
	_camera_original_offset = camera.offset


# ─── Camera Shake ────────────────────────────────────────────────────────────

## Shakes the camera with random offsets.
## [param intensity] Maximum pixel offset per frame.
## [param duration]  How long the shake lasts in seconds.
func shake_camera(intensity: float = 8.0, duration: float = 0.3) -> void:
	if not _ensure_camera():
		return
	_kill_tween("shake")
	_camera_original_offset = _camera.offset

	var tween := create_tween()
	_tweens["shake"] = tween

	var steps := int(duration / 0.02)
	for i in steps:
		var offset := Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(_camera, "offset", _camera_original_offset + offset, 0.02)

	# Reset to original position at the end
	tween.tween_property(_camera, "offset", _camera_original_offset, 0.02)


# ─── Screen Flash ────────────────────────────────────────────────────────────

## Flashes the overlay to [param color] then fades it out.
## [param duration] Total time for the full flash + fade.
func flash_screen(color: Color = Color.WHITE, duration: float = 0.15) -> void:
	_kill_tween("flash")

	_overlay.color = Color(color.r, color.g, color.b, 0.6)
	var tween := create_tween()
	_tweens["flash"] = tween
	tween.tween_property(_overlay, "color:a", 0.0, duration)


# ─── Screen Tint (for physics states) ───────────────────────────────────────

## Smoothly transitions the CanvasModulate colour.
## Pass [code]Color.WHITE[/code] to remove the tint.
## [param color]    Target tint colour.
## [param duration] Transition duration in seconds.
func set_screen_tint(color: Color = Color.WHITE, duration: float = 0.5) -> void:
	_kill_tween("tint")

	var tween := create_tween()
	_tweens["tint"] = tween
	tween.tween_property(_canvas_modulate, "color", color, duration)


# ─── Slow Motion ─────────────────────────────────────────────────────────────

## Temporarily changes the engine time-scale.
## [param time_scale] Target time-scale (0.0 – 1.0 for slow, >1 for fast).
## [param duration]   Real-time seconds the effect lasts before snapping back.
func slow_motion(time_scale: float = 0.3, duration: float = 1.0) -> void:
	_kill_tween("slowmo")

	Engine.time_scale = time_scale

	# We use a real-time tween so it isn't affected by the changed time-scale.
	var tween := create_tween()
	_tweens["slowmo"] = tween
	tween.set_speed_scale(1.0 / time_scale)  # Compensate for slow time
	tween.tween_interval(duration)
	tween.tween_callback(func(): Engine.time_scale = 1.0)


# ─── Camera Zoom ─────────────────────────────────────────────────────────────

## Smoothly zooms the camera.
## [param zoom_level] Target uniform zoom (>1 = zoom in, <1 = zoom out).
## [param duration]   Transition duration in seconds.
func zoom_camera(zoom_level: float = 1.0, duration: float = 0.4) -> void:
	if not _ensure_camera():
		return
	_kill_tween("zoom")

	var target := Vector2(zoom_level, zoom_level)
	var tween := create_tween()
	_tweens["zoom"] = tween
	tween.tween_property(_camera, "zoom", target, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


# ─── Reset everything ───────────────────────────────────────────────────────

## Kills all running effects and resets visuals to default.
func reset_all() -> void:
	for key in _tweens.keys():
		_kill_tween(key)

	_overlay.color = Color(0, 0, 0, 0)
	_canvas_modulate.color = Color.WHITE
	Engine.time_scale = 1.0

	if _camera:
		_camera.offset = _camera_original_offset
		_camera.zoom = Vector2.ONE


# ─── Helpers ─────────────────────────────────────────────────────────────────

## Kills an existing tween for the given effect key if one is running.
func _kill_tween(key: String) -> void:
	if _tweens.has(key) and _tweens[key] is Tween and _tweens[key].is_valid():
		_tweens[key].kill()
	_tweens.erase(key)


## Tries to locate a Camera2D in the scene tree if one isn't registered yet.
func _ensure_camera() -> bool:
	if _camera and is_instance_valid(_camera):
		return true
	# Attempt to auto-find
	var vp := get_viewport()
	if vp:
		_camera = _find_camera_in(vp)
	if _camera:
		_camera_original_offset = _camera.offset
	return _camera != null


## Recursively searches the subtree for the first Camera2D.
func _find_camera_in(node: Node) -> Camera2D:
	if node is Camera2D:
		return node
	for child in node.get_children():
		var found := _find_camera_in(child)
		if found:
			return found
	return null
