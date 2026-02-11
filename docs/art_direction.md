# Art Direction: Definitely Normal Physics

## 🎨 Visual Style
**"Deceptive Minimalism"**
The game should look clean, stable, and "normal" at first glance—like a standard prototyping environment or a basic platformer. This maximizes the impact when things go wrong (gravity flips, friction breaks).

*   **Geometry:** Simple geometric shapes (squares, rectangles). Clean lines.
*   **Atmosphere:** Sterile laboratory / Simulation vibes.
*   **VFX:** excessive "juice" (particles, screenshake, squash & stretch) to compensate for simple geometry.

## 🌈 Color Palette
Uses a base neutral palette + strong accents for physics states.

### Base
*   **Background:** `#1a1a1a` (Dark Grey)
*   **Platforms:** `#ffffff` (White) with subtle grey outline
*   **Hazards (Spikes):** `#ff4444` (Danger Red)
*   **Player:** `#ffd700` (Gold/Yellow) - stands out against everything

### Physics State Tints (Visual Feedback)
These tints apply to the **entire screen** or **vignette** to signal state changes instantly.
*   **Normal:** No Tint
*   **Reverse Gravity:** `#00ffff` (Cyan)
*   **Low Gravity:** `#8080ff` (Periwinkle)
*   **High Gravity:** `#ff0000` (Deep Red)
*   **Zero Friction:** `#aaddff` (Icy Blue)
*   **Super Friction:** `#8b4513` (Mud Brown)
*   **Bouncy:** `#ff69b4` (Hot Pink)

## 📦 Asset List (32x32 Pixel Art)

### Player (`player.png`)
A simple cube, but responsive.
*   **Idle:** Blinking eyes (2 frames)
*   **Run:** Rolling or slight lean + dust particles (4 frames)
*   **Jump:** Squash down, then stretch up (1 frame)
*   **Fall:** Stretched vertically, slightly panicked eyes (1 frame)
*   **Death:** Explodes into smaller cubes (Particle effect)

### Environment (`tileset.png`)
*   **Floor/Wall:** 32x32 white block with inner grey border.
*   **Spike:** Simple triangle. Glows slightly.
*   **Checkpoint:** A flag or a holographic "save" icon.
*   **Exit:** A door or portal. Emits particles.

### Triggers (`trigger.png`)
*   **Enter:** Semi-transparent colored zones matching the state tint.
*   **Timer:** A clock icon or counting down number.

### UI Elements
*   **Crosshair/Indicator:** Detailed enough to show gravity direction.
*   **Buttons:** Chunky, clickable, satisfying press animation.

## ✨ Visual Effects ("Juice")
*   **Dust:** Small white clouds when jumping/landing.
*   **Impact:** Screen shake on death or heavy landing (High G).
*   **Speed:** Speed lines when moving fast (Low Friction/falling).
*   **Transition:** Glitch effect or chromatic aberration during physics switches.
