import wave
import math
import os
import random
import struct

def generate_tone(filepath, frequency, duration, wave_type='sine', volume=0.5):
    sample_rate = 44100
    n_frames = int(sample_rate * duration)
    
    try:
        with wave.open(filepath, 'w') as wav_file:
            wav_file.setparams((1, 2, sample_rate, n_frames, 'NONE', 'not compressed'))
            
            for i in range(n_frames):
                t = i / sample_rate
                if wave_type == 'sine':
                    value = math.sin(2 * math.pi * frequency * t)
                elif wave_type == 'square':
                    value = 1.0 if math.sin(2 * math.pi * frequency * t) > 0 else -1.0
                elif wave_type == 'saw':
                    value = 2.0 * (t * frequency - math.floor(t * frequency + 0.5))
                elif wave_type == 'noise':
                    value = random.uniform(-1, 1)
                else:
                    value = 0.0
                
                # Envelope (fade out)
                envelope = 1.0 - (i / n_frames)
                value = value * volume * envelope
                
                # Convert to 16-bit PCM
                sample = int(value * 32767.0)
                wav_file.writeframes(struct.pack('<h', sample))
                
        print(f"Generated: {filepath}")
    except Exception as e:
        print(f"Error generating {filepath}: {e}")

def main():
    base_dir = "/Users/rajkrish0608/PROJECT DETAILS/Definitely Normal Physics/assets/audio"
    music_dir = os.path.join(base_dir, "music")
    sfx_dir = os.path.join(base_dir, "sfx")
    
    os.makedirs(music_dir, exist_ok=True)
    os.makedirs(sfx_dir, exist_ok=True)
    
    # SFX List from Checklist
    sfx_list = [
        ("jump.wav", 440.0, 0.1, 'sine'),
        ("land.wav", 110.0, 0.1, 'square'),
        ("death.wav", 55.0, 0.4, 'saw'),
        ("button_click.wav", 880.0, 0.05, 'sine'),
        ("physics_change.wav", 600.0, 0.3, 'saw'),
        ("checkpoint.wav", 1200.0, 0.3, 'sine'),
        ("level_complete.wav", 500.0, 1.0, 'square'),
        ("powerup.wav", 1000.0, 0.2, 'sine'),
        ("teleport.wav", 1500.0, 0.1, 'saw'),
        ("physics_reverse.wav", 300.0, 0.5, 'square'),
        ("ice_slip.wav", 800.0, 0.2, 'noise')
    ]
    
    for name, freq, dur, wtype in sfx_list:
        generate_tone(os.path.join(sfx_dir, name), freq, dur, wtype)
        
    # Music List
    music_list = [
        ("menu_theme.wav", 220.0, 5.0, 'sine'), # Short loops
        ("level_theme_1.wav", 330.0, 5.0, 'sine'),
        ("level_theme_2.wav", 280.0, 5.0, 'square'),
        ("boss_theme.wav", 110.0, 5.0, 'saw')
    ]
    
    for name, freq, dur, wtype in music_list:
        generate_tone(os.path.join(music_dir, name), freq, dur, wtype)

if __name__ == "__main__":
    main()
