## PhysicsState — Abstract Base Class for All Physics Behaviours
##
## Every physics "mode" in the game (normal, reverse gravity, low gravity, etc.)
## extends this class.  The PhysicsManager holds instances and swaps between them
## at runtime.
##
## ── How to create a new physics state ──
## 1. Create a new .gd file in res://scripts/physics_states/
## 2. Write:  extends "res://scripts/physics_states/PhysicsState.gd"
## 3. Override _init() to set the properties you want to change
## 4. Override get_state_name() to return a human-readable label
## 5. Register the new state in PhysicsManager._load_all_states()
##
## The PlayerController reads these properties every physics frame to
## determine how the character should move, jump, and feel.
class_name PhysicsState
extends RefCounted


# ─── Movement / Physics Properties ───────────────────────────────────────────

## Multiplier on the global gravity magnitude.
## 1.0 = normal,  <1.0 = floaty (moon),  >1.0 = heavy (Jupiter).
var gravity_scale: float = 1.0

## Direction gravity pulls the player.
## Vector2.DOWN is standard;  Vector2.UP gives reverse gravity.
var gravity_direction: Vector2 = Vector2.DOWN

## Ground friction factor (0.0 = ice, 0.5 = normal, 1.0 = instant stop).
## Applied as a deceleration multiplier when the player releases movement keys.
var friction: float = 0.5

## Bounciness when hitting the ground (0.0 = no bounce, 1.0 = full rebound).
var bounce: float = 0.0

## Multiplier on the player's max horizontal speed.
var speed_multiplier: float = 1.0

## Multiplier on the player's jump velocity.
var jump_multiplier: float = 1.0


# ─── Input Modifiers ─────────────────────────────────────────────────────────

## When true, left/right inputs are swapped.
var controls_reversed: bool = false

## Seconds of delay added between physical input and in-game action.
## 0.0 = no delay (responsive),  0.3 = noticeable lag.
var input_delay: float = 0.0


# ─── Visual / Audio Feedback ─────────────────────────────────────────────────

## Colour tint applied to the screen via CanvasModulate while this state
## is active.  Color.WHITE = no tint.
var tint_color: Color = Color.WHITE

## Name of a particle effect to play while this state is active.
## Empty string = no particle.  Matched by a particle spawner script.
var particle_effect: String = ""

## Name of a one-shot sound effect to play when this state activates.
## Empty string = no sound.  Matched by AudioManager.play_sfx().
var sound_effect: String = ""


# ─── Virtual Methods ─────────────────────────────────────────────────────────

## Called when this state becomes the active physics mode.
## Override to play entry sounds, start particles, etc.
func on_enter() -> void:
	pass


## Called when this state is replaced by another physics mode.
## Override to clean up particles, reset visuals, etc.
func on_exit() -> void:
	pass


## Called every physics frame while this state is active.
## Override to apply per-frame effects (e.g., wind push, random direction
## changes, pulsating gravity).
## [param delta]  Physics frame delta time.
## [param player] Reference to the CharacterBody2D player node.
func update_physics(_delta: float, _player: CharacterBody2D) -> void:
	pass


## Returns a human-readable name for this state (shown in HUD / debug).
func get_state_name() -> String:
	return "Base State"
