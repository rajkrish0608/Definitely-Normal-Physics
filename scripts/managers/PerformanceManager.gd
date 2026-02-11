extends Node

## PerformanceManager — Dynamic Quality Adjustment (Autoload Singleton)
##
## Monitors FPS and adjusts visual quality settings to maintain target framerate.
## Useful for mobile devices with varying hardware.

# Settings
const TARGET_FPS: int = 60
const CHECK_INTERVAL: float = 2.0 # Check every 2 seconds
const FPS_TOLERANCE: int = 5 # Allow dropping to 55

# State
var _timer: float = 0.0
var _low_power_mode: bool = false
var _resolution_scale: float = 1.0

func _ready() -> void:
	# Default mobile settings
	if OS.has_feature("mobile"):
		RenderingServer.viewport_set_usage_mode(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_USAGE_2D)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= CHECK_INTERVAL:
		_timer = 0.0
		_check_performance()

func _check_performance() -> void:
	var fps = Engine.get_frames_per_second()
	
	if fps < (TARGET_FPS - FPS_TOLERANCE):
		_downgrade_quality()
	elif fps >= TARGET_FPS and _low_power_mode:
		_attempt_upgrade()

func _downgrade_quality() -> void:
	if _low_power_mode:
		# Already low, try resolution scaling
		if _resolution_scale > 0.5:
			_resolution_scale -= 0.1
			get_viewport().scaling_3d_scale = _resolution_scale
			print("[Performance] Reducing resolution scale to %.1f" % _resolution_scale)
		return

	print("[Performance] FPS dropped to %d. Enabling Low Power Mode." % Engine.get_frames_per_second())
	_low_power_mode = true
	
	# Disable expensive effects
	_set_particles_enabled(false)
	# Reduce physics tick rate slightly if CPU bound (careful with physics simulation)
	# Engine.physics_ticks_per_second = 30 
	
func _attempt_upgrade() -> void:
	# Only upgrade if FPS is super stable (e.g. 60) for a while
	# For now, we prefer stability, so we don't auto-upgrade easily.
	pass

func _set_particles_enabled(enabled: bool) -> void:
	# This would need to iterate over particle systems or set a global flag
	# For now, we can toggle a specific group
	get_tree().call_group("Particles", "set_emitting", enabled)
