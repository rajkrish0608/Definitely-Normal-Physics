## SceneTransition — Fade-based Scene Switcher (Autoload Singleton)
##
## Provides smooth fade-to-black (or any colour) transitions when
## changing scenes.  Because it lives on its own CanvasLayer it
## persists across scene changes.
##
## Usage:
##   SceneTransition.fade_to_scene("res://levels/world_1/level_03.tscn")
##   SceneTransition.fade_to_scene("res://scenes/ui/MainMenu.tscn", 0.8, Color.WHITE)
extends CanvasLayer


## Emitted after the new scene has fully faded in.
signal transition_finished

## The overlay ColorRect used for the fade effect.
var _overlay: ColorRect = null

## True while a transition is in progress (prevents double-fires).
var _transitioning: bool = false


func _ready() -> void:
	# Keep this layer above everything except debug overlays
	layer = 99

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)  # Start fully transparent
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)


## Fades the screen to [param fade_color], swaps the scene, then
## fades back to transparent.
## [param scene_path] Resource path of the target scene ("res://…").
## [param duration]   Total transition time (half for fade-out, half for fade-in).
## [param fade_color] Colour of the fade overlay (default: black).
func fade_to_scene(
	scene_path: String,
	duration: float = 0.5,
	fade_color: Color = Color.BLACK
) -> void:
	if _transitioning:
		push_warning("[SceneTransition] Transition already in progress — ignoring.")
		return
	_transitioning = true

	var half := duration * 0.5

	# ── Phase 1: Fade out (transparent → opaque) ──
	_overlay.color = Color(fade_color.r, fade_color.g, fade_color.b, 0.0)
	var tween_out := create_tween()
	tween_out.tween_property(_overlay, "color:a", 1.0, half)
	await tween_out.finished

	# ── Phase 2: Swap scene ──
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("[SceneTransition] Failed to load scene: %s (error %d)" % [scene_path, err])
		_transitioning = false
		return

	# Give the new scene one frame to initialise
	await get_tree().process_frame

	# ── Phase 3: Fade in (opaque → transparent) ──
	var tween_in := create_tween()
	tween_in.tween_property(_overlay, "color:a", 0.0, half)
	await tween_in.finished

	_transitioning = false
	transition_finished.emit()


## Instant cut to a scene with no animation.
func cut_to_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


## Returns true while a transition animation is playing.
func is_transitioning() -> bool:
	return _transitioning
