## EventBus — Global Signal Hub (Autoload Singleton)
##
## A decoupled communication backbone for the entire game.
## Systems emit signals here; other systems connect to listen.
## This avoids direct references between unrelated scripts
## (e.g., the player doesn't need to know the HUD exists).
##
## Usage:
##   EventBus.physics_changed.emit("ReverseGravity")
##   EventBus.player_died.connect(_on_player_died)
extends Node


# ─── Physics ──────────────────────────────────────────────────────────────────

## Emitted when the active PhysicsState changes.
## [param state_name] The name string of the newly active physics state.
signal physics_changed(state_name: String)


# ─── Player lifecycle ────────────────────────────────────────────────────────

## Emitted when the player dies (touches hazard, falls off, etc.).
signal player_died()

## Emitted after the player has respawned at a checkpoint.
## [param position] World-space position the player respawned at.
signal player_respawned(position: Vector2)


# ─── Level flow ──────────────────────────────────────────────────────────────

## Emitted when a new level scene has finished loading.
## [param world] World number (1-based).
## [param level] Level number within that world (1-based).
signal level_loaded(world: int, level: int)

## Emitted when the player reaches the exit of the current level.
## [param world] World number of the completed level.
## [param level] Level number of the completed level.
signal level_complete(world: int, level: int)

## Emitted when the player touches a checkpoint flag.
## [param position] World-space position of the checkpoint.
signal checkpoint_reached(position: Vector2)


# ─── Stats ───────────────────────────────────────────────────────────────────

## Emitted whenever the death counter for the current level changes.
## [param count] New cumulative death count for this level attempt.
signal death_count_updated(count: int)

## Emitted when the player collects a bonus star pickup.
## [param star_id] Unique identifier of the collected star.
signal star_collected(star_id: int)


# ─── Debug helpers ───────────────────────────────────────────────────────────

## When true, every signal emission is printed to the console.
## Automatically enabled in debug (editor / debug export) builds.
var debug_logging: bool = OS.is_debug_build()


func _ready() -> void:
	if debug_logging:
		_connect_debug_listeners()


## Connects lightweight listeners that print signal names when fired.
func _connect_debug_listeners() -> void:
	physics_changed.connect(func(s): _log("physics_changed → %s" % s))
	player_died.connect(func(): _log("player_died"))
	player_respawned.connect(func(p): _log("player_respawned → %s" % str(p)))
	level_loaded.connect(func(w, l): _log("level_loaded → W%d-L%d" % [w, l]))
	level_complete.connect(func(w, l): _log("level_complete → W%d-L%d" % [w, l]))
	checkpoint_reached.connect(func(p): _log("checkpoint_reached → %s" % str(p)))
	death_count_updated.connect(func(c): _log("death_count_updated → %d" % c))
	star_collected.connect(func(id): _log("star_collected → %d" % id))


func _log(msg: String) -> void:
	print("[EventBus] %s" % msg)
