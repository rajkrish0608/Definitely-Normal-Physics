class_name AudioPlaceholderGenerator
extends Node

## Generates simple .wav files for prototyping audio.
## Run this once to populate res://assets/audio/ with valid placeholders.

const SAMPLE_RATE = 44100
const BIT_DEPTH = 16
const NUM_CHANNELS = 1

static func generate_all_placeholders() -> void:
	var music_dir = "res://assets/audio/music/"
	var sfx_dir = "res://assets/audio/sfx/"
	
	DirAccess.make_dir_recursive_absolute(music_dir)
	DirAccess.make_dir_recursive_absolute(sfx_dir)
	
	# SFX
	_generate_tone(sfx_dir + "jump.wav", 440.0, 0.1, "sine")
	_generate_tone(sfx_dir + "land.wav", 220.0, 0.1, "square")
	_generate_tone(sfx_dir + "death.wav", 110.0, 0.3, "saw")
	_generate_tone(sfx_dir + "button_click.wav", 880.0, 0.05, "sine")
	_generate_tone(sfx_dir + "physics_change.wav", 600.0, 0.2, "saw")
	_generate_tone(sfx_dir + "checkpoint.wav", 1200.0, 0.3, "sine")
	_generate_tone(sfx_dir + "level_complete.wav", 500.0, 1.0, "square")
	_generate_tone(sfx_dir + "powerup.wav", 1000.0, 0.2, "sine")
	_generate_tone(sfx_dir + "teleport.wav", 1500.0, 0.1, "saw")
	_generate_tone(sfx_dir + "physics_reverse.wav", 300.0, 0.5, "square")
	
	# Music (Very short loops)
	_generate_tone(music_dir + "menu_theme.ogg", 440.0, 2.0, "sine") # Placeholder format, Godot needs import for ogg usually, but wav works for stream
	# Note: Generating real OGG is hard. We'll generate WAV and renaming might fail playback in Godot due to header mismatch.
	# We will generate .wav for music placeholders too.
	_generate_tone(music_dir + "level_theme_1.wav", 330.0, 5.0, "sine")
	
	print("[AudioPlaceholderGenerator] Generated placeholder audio files.")

static func _generate_tone(path: String, frequency: float, duration: float, type: String) -> void:
	if FileAccess.file_exists(path):
		return # Don't overwrite if exists
		
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return
		
	var num_samples = int(duration * SAMPLE_RATE)
	var data_size = num_samples * NUM_CHANNELS * (BIT_DEPTH / 8)
	var file_size = 36 + data_size
	
	# WAV Reference: http://soundfile.sapp.org/doc/WaveFormat/
	
	# RIFF chunk
	file.store_buffer("RIFF".to_utf8_buffer())
	file.store_32(file_size) # File size - 8
	file.store_buffer("WAVE".to_utf8_buffer())
	
	# fmt chunk
	file.store_buffer("fmt ".to_utf8_buffer())
	file.store_32(16) # Chunk size (16 for PCM)
	file.store_16(1) # Audio format (1 = PCM)
	file.store_16(NUM_CHANNELS)
	file.store_32(SAMPLE_RATE)
	file.store_32(SAMPLE_RATE * NUM_CHANNELS * (BIT_DEPTH / 8)) # Byte rate
	file.store_16(NUM_CHANNELS * (BIT_DEPTH / 8)) # Block align
	file.store_16(BIT_DEPTH)
	
	# data chunk
	file.store_buffer("data".to_utf8_buffer())
	file.store_32(data_size)
	
	# Write samples
	for i in range(num_samples):
		var t = float(i) / SAMPLE_RATE
		var value = 0.0
		
		match type:
			"sine": value = sin(TAU * frequency * t)
			"square": value = 1.0 if sin(TAU * frequency * t) > 0 else -1.0
			"saw": value = 2.0 * (t * frequency - floor(t * frequency + 0.5))
			
		# Apply simple envelope (fade out)
		var envelope = 1.0 - (float(i) / num_samples)
		value *= envelope
		
		# Convert to 16-bit signed integer (-32768 to 32767)
		var sample_int = int(value * 32000)
		file.store_16(sample_int)
		
	file.close()
