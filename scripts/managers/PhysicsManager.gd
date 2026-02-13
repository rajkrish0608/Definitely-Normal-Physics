## PhysicsManager — Core Physics State Machine (Autoload Singleton)
##
## Owns every PhysicsState instance, tracks the currently active one,
## and exposes a clean API for the rest of the game to query or change
## physics at runtime.
##
## ── Architecture notes ──
## • States are plain RefCounted objects (not nodes) — cheap to hold.
## • A state stack allows push/pop for temporary overrides
##   (e.g., "low gravity for 5 seconds then revert").
## • On every state change we:
##   1. Call old_state.on_exit()
##   2. Call new_state.on_enter()
##   3. Play the state's sound_effect via AudioManager (if available)
##   4. Apply the state's tint_color via ScreenEffects
##   5. Emit EventBus.physics_changed
##
## Usage:
##   PhysicsManager.set_state("ReverseGravity")
##   var g = PhysicsManager.get_current_gravity()
##   PhysicsManager.push_state("LowGravity")
##   PhysicsManager.pop_state()  # reverts to previous
extends Node


# ─── Constants ───────────────────────────────────────────────────────────────

## Base gravity magnitude used by the project (pixels/s²).
## This is multiplied by PhysicsState.gravity_scale and
## PhysicsState.gravity_direction to produce the final vector.
const BASE_GRAVITY: float = 980.0


# ─── State storage ───────────────────────────────────────────────────────────

## Dictionary mapping state name (String) → PhysicsState instance.
var _states: Dictionary = {}

## The currently active physics state.
var current_state: PhysicsState = null

## Stack for push/pop state layering.
## Each entry is the state *name* (String).
var _state_stack: Array[String] = []


# ─── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
	_load_all_states()
	# Start with normal physics (no transition effects)
	set_state("Normal", true)


## Instantiates every registered physics state and stores it in _states.
## When you create a new PhysicsState subclass, add it here.
func _load_all_states() -> void:
	var state_classes: Array = [
		preload("res://scripts/physics_states/NormalPhysics.gd"),
		preload("res://scripts/physics_states/ReverseGravity.gd"),
		preload("res://scripts/physics_states/LowGravity.gd"),
		preload("res://scripts/physics_states/HighGravity.gd"),
		preload("res://scripts/physics_states/ZeroFriction.gd"),
		preload("res://scripts/physics_states/SuperFriction.gd"),
		preload("res://scripts/physics_states/BouncyPhysics.gd"),
		# Extended States (World 4+)
		preload("res://scripts/physics_states/SlowMotion.gd"),
		preload("res://scripts/physics_states/FastForward.gd"),
		preload("res://scripts/physics_states/TeleportJump.gd"),
		preload("res://scripts/physics_states/DoubleJump.gd"),
		preload("res://scripts/physics_states/InvertedControls.gd"),
		preload("res://scripts/physics_states/DelayedInput.gd"),
		preload("res://scripts/physics_states/RandomDirection.gd"),
		preload("res://scripts/physics_states/SizeChange.gd"),
		preload("res://scripts/physics_states/Underwater.gd"),
		preload("res://scripts/physics_states/WindForce.gd"),
		preload("res://scripts/physics_states/PhaseThrough.gd"),
		preload("res://scripts/physics_states/MagnetPlatforms.gd"),
		preload("res://scripts/physics_states/WallWalk.gd"),
	]

	for script in state_classes:
		var instance: PhysicsState = script.new()
		var sname: String = instance.get_state_name()
		_states[sname] = instance

	if OS.is_debug_build():
		print("[PhysicsManager] Loaded %d states: %s" % [_states.size(), ", ".join(_states.keys())])


# ─── State Switching ─────────────────────────────────────────────────────────

## Switches to a new physics state by name.
## [param state_name] Must exactly match get_state_name() of a loaded state.
## [param instant]    If true, skip tint transition (used at level start).
func set_state(state_name: String, instant: bool = false) -> void:
	if not _states.has(state_name):
		push_error("[PhysicsManager] Unknown state: '%s'. Available: %s" % [state_name, ", ".join(_states.keys())])
		return

	var new_state: PhysicsState = _states[state_name]

	# Don't re-enter the same state
	if current_state == new_state:
		return

	# ── Exit old state ──
	if current_state:
		current_state.on_exit()

	var old_name := current_state.get_state_name() if current_state else "None"

	# ── Enter new state ──
	current_state = new_state
	current_state.on_enter()

	# ── Play activation sound ──
	if current_state.sound_effect != "":
		_play_state_sound(current_state.sound_effect)

	# ── Apply screen tint ──
	if instant:
		# Instant tint (no animation) — used at level load
		ScreenEffects.set_screen_tint(current_state.tint_color, 0.0)
	else:
		ScreenEffects.set_screen_tint(current_state.tint_color, 0.4)

	# ── Notify the game ──
	EventBus.physics_changed.emit(state_name)

	if OS.is_debug_build():
		print("[PhysicsManager] %s → %s" % [old_name, state_name])


# ─── Push / Pop Stack ───────────────────────────────────────────────────────

## Saves the current state name and transitions to a new one.
## Use this for temporary physics changes (e.g., "bouncy for 3 seconds").
func push_state(state_name: String) -> void:
	if current_state:
		_state_stack.push_back(current_state.get_state_name())
	set_state(state_name)


## Reverts to the most recently pushed state.
## Does nothing (and warns) if the stack is empty.
func pop_state() -> void:
	if _state_stack.is_empty():
		push_warning("[PhysicsManager] pop_state() called but stack is empty — defaulting to Normal.")
		set_state("Normal")
		return
	var previous: String = _state_stack.pop_back()
	set_state(previous)


# ─── Query Helpers ───────────────────────────────────────────────────────────

## Returns the gravity vector for this frame:
##   direction × scale × BASE_GRAVITY
func get_current_gravity() -> Vector2:
	if not current_state:
		return Vector2.DOWN * BASE_GRAVITY
	return current_state.gravity_direction * current_state.gravity_scale * BASE_GRAVITY


## Returns the current friction factor (0.0 – 1.0).
func get_current_friction() -> float:
	if not current_state:
		return 0.5
	return current_state.friction


## Returns the current speed multiplier.
func get_current_speed_multiplier() -> float:
	if not current_state:
		return 1.0
	return current_state.speed_multiplier


## Returns the current jump multiplier.
func get_current_jump_multiplier() -> float:
	if not current_state:
		return 1.0
	return current_state.jump_multiplier


## Returns true if any state in the registry matches [param state_name].
func has_state(state_name: String) -> bool:
	return _states.has(state_name)


## Returns a list of all registered state names.
func get_all_state_names() -> Array[String]:
	var names: Array[String] = []
	for key in _states.keys():
		names.append(key)
	return names


# ─── Internal Helpers ────────────────────────────────────────────────────────

## Plays a sound effect through AudioManager if the singleton is available.
func _play_state_sound(sfx_name: String) -> void:
	if Engine.has_singleton("AudioManager"):
		# AudioManager will be added later; this is forward-compatible.
		pass
	elif has_node("/root/AudioManager"):
		get_node("/root/AudioManager").call("play_sfx", sfx_name)
	else:
		# AudioManager not yet loaded — silently skip
		if OS.is_debug_build():
			print("[PhysicsManager] AudioManager not found — skipping SFX '%s'" % sfx_name)
