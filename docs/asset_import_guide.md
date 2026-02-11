# Asset Import Settings

## Texture Settings
For all pixel art look (crisp edges, no blur):
1.  Select the image file in Godot FileSystem.
2.  Go to **Import** tab.
3.  Preset: **2D Pixel** (resets flags like Filter).
4.  **Compress Mode:** Lossless (PNG).
5.  **Filter:** OFF (Nearest Neighbor).
6.  Click **Reimport**.

## Sprite Sheet Breakdown

### `player_spritesheet.webp` (32x32 grid)
*   **Idle:** Row 1 (Frames 0-3)
*   **Run:** Row 2 (Frames 4-7)
*   **Jump/Fall:** Row 3 (Frames 8-11)
    *   Jump Start: Frame 8
    *   Rising: Frame 9
    *   Apex: Frame 10
    *   Falling: Frame 11
*   **Death:** Row 4 (Frames 12-15)

### `tileset_environment.webp` (32x32 grid)
*   Create a **TileSet** resource.
*   **Physics Layer 0:** Collision for Ground/Wall/One-way.
*   **Physics Layer 1:** Hazard collision (Spikes).
*   **Auto-Tiling:** Use terrain sets for connecting ground blocks if needed, or simple atlas.

### `ui_icons_and_particles.webp`
*   Use `AtlasTexture` to slice out specific icons for the HUD.
