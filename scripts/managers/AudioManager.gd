## AudioManager — Music & SFX Controller (Autoload Singleton)
##
## Handles all audio playback with volume control, music crossfading,
## and SFX pooling for performance.
##
## ── Usage ──
##   AudioManager.play_music("level_theme_01", 1.0)
##   AudioManager.play_sfx("jump", 1.0)
##   AudioManager.set_music_volume(0.5)
extends Node


# ─── Audio Players ──────────────────────────────────────────────────────────

## Primary music player.
var _music_player: AudioStreamPlayer = null

## Secondary music player for crossfading.
var _music_player_alt: AudioStreamPlayer = null

## Pool of SFX players (reused for performance).
var _sfx_pool: Array[AudioStreamPlayer] = []

## Number of SFX players to pre-create.
const SFX_POOL_SIZE: int = 8


# ─── State ──────────────────────────────────────────────────────────────────

## Currently playing music track name.
var _current_music: String = ""


# ─── Lifecycle ──────────────────────────────────────────────────────────────

func _ready() -> void:
	_setup_audio_buses()
	_create_music_players()
	_create_sfx_pool()


## Creates audio buses for separate music/SFX volume control.
func _setup_audio_buses() -> void:
	# Check if buses already exist
	var music_bus := AudioServer.get_bus_index("Music")
	if music_bus == -1:
		AudioServer.add_bus()
		music_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(music_bus, "Music")
		AudioServer.set_bus_send(music_bus, "Master")

	var sfx_bus := AudioServer.get_bus_index("SFX")
	if sfx_bus == -1:
		AudioServer.add_bus()
		sfx_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_bus, "SFX")
		AudioServer.set_bus_send(sfx_bus, "Master")


## Creates two music players for crossfading.
func _create_music_players() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	_music_player_alt = AudioStreamPlayer.new()
	_music_player_alt.bus = "Music"
	add_child(_music_player_alt)


## Pre-creates a pool of SFX players.
func _create_sfx_pool() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_pool.append(player)


# ─── Music ──────────────────────────────────────────────────────────────────

## Plays a music track with optional crossfade.
## [param track_name] File name without extension (e.g., "level_theme_01").
## [param fade_duration] Crossfade time in seconds.
func play_music(track_name: String, fade_duration: float = 1.0) -> void:
	if track_name == _current_music and _music_player.playing:
		return  # Already playing this track

	var path := "res://assets/audio/music/%s.ogg" % track_name
	if not ResourceLoader.exists(path):
		push_warning("[AudioManager] Music not found: %s" % path)
		return

	var stream := load(path) as AudioStream
	if not stream:
		return

	# Swap players for crossfade
	var old_player := _music_player
	var new_player := _music_player_alt
	_music_player = new_player
	_music_player_alt = old_player

	# Fade out old, fade in new
	if fade_duration > 0:
		var tween := create_tween()
		tween.set_parallel(true)
		if old_player.playing:
			tween.tween_property(old_player, "volume_db", -80, fade_duration)
		tween.tween_property(new_player, "volume_db", 0, fade_duration)
		tween.chain().tween_callback(old_player.stop)
	else:
		old_player.stop()

	new_player.stream = stream
	new_player.play()
	_current_music = track_name


## Stops music playback.
func stop_music(fade_duration: float = 1.0) -> void:
	if fade_duration > 0:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", -80, fade_duration)
		tween.tween_callback(_music_player.stop)
	else:
		_music_player.stop()
	_current_music = ""


# ─── Sound Effects ──────────────────────────────────────────────────────────

## Plays a one-shot sound effect.
## [param sfx_name] File name without extension (e.g., "jump").
## [param volume_modifier] Multiplier on base volume (0.0 - 2.0).
func play_sfx(sfx_name: String, volume_modifier: float = 1.0) -> void:
	var path := "res://assets/audio/sfx/%s.ogg" % sfx_name
	if not ResourceLoader.exists(path):
		# Silently fail for missing SFX (not critical)
		return

	var stream := load(path) as AudioStream
	if not stream:
		return

	var player := _get_available_sfx_player()
	if not player:
		push_warning("[AudioManager] All SFX players busy, skipping: %s" % sfx_name)
		return

	player.stream = stream
	player.volume_db = linear_to_db(volume_modifier)
	player.play()


## Returns the first available (non-playing) SFX player from the pool.
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_pool:
		if not player.playing:
			return player
	return null


# ─── Volume Control ─────────────────────────────────────────────────────────

## Sets music volume (0.0 = silent, 1.0 = full).
func set_music_volume(volume: float) -> void:
	var db := linear_to_db(clamp(volume, 0.0, 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)


## Sets SFX volume (0.0 = silent, 1.0 = full).
func set_sfx_volume(volume: float) -> void:
	var db := linear_to_db(clamp(volume, 0.0, 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)


## Gets current music volume (0.0 - 1.0).
func get_music_volume() -> float:
	var db := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	return db_to_linear(db)


## Gets current SFX volume (0.0 - 1.0).
func get_sfx_volume() -> float:
	var db := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	return db_to_linear(db)
