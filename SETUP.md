# Development Setup Guide

*Definitely Normal Physics* is built with Godot 4.2. Follow these setup instructions to contribute to the codebase.

## Prerequisites
- **Godot Engine:** Version 4.2+ (Standard Edition)
- **Git**

## Project Structure
```
res://
├── .godot/             # Editor metadata
├── levels/             # Game levels
│   ├── json/           # JSON definition files (source of truth)
│   └── *.tscn          # Godot scenes (for editing visuals)
├── scenes/             # Reusable components
│   ├── player/         # Player character scenes
│   ├── environment/    # Blocks, triggers, background
│   └── ui/             # Menus, HUD, dialogues
├── scripts/            # GDScript source files
│   ├── managers/       # Global singletons (PhysicsManager, LevelManager)
│   ├── physics_states/ # Physics behaviour implementations
│   └── player/         # Player logic
└── tests/              # Automated tests (TestRunner.gd)
```

## How to Create New Content

### 1. Creating a New Physics State
1. Create a script in `scripts/physics_states/` extending `PhysicsState`.
2. Override `apply_gravity()`, `apply_friction()`, or `handle_jump()`.
3. Give it a `state_name` constant (e.g., "TimeWarp").
4. Register it in `PhysicsManager.gd` -> `_states` dictionary.
5. Add a colour/label to `PlayerController.STATE_COLORS` and `HUD.STATE_DISPLAY`.

### 2. Designing a Level
1. Create a new `.json` file in `levels/json/` following the schema.
2. Define platforms, start/end points, and triggers.
   - Example triggers: `{ "type": "physics_change", "state": "ReverseGravity" }`
3. Add the level to `level_registry.json`.
4. (Optional) Create a `.tscn` visual scene if custom art is needed.

## Building and Exporting

### Windows / macOS / Linux
1. Go to **Project > Export**.
2. Select your presets (Windows Desktop, macOS, Linux/X11).
3. Ensure export templates are installed.
4. Click **Export Project**.

### Web (HTML5)
1. Select **Web** preset.
2. Enable "Threads" support if cross-origin isolation is configured (otherwise disable).
3. Export to an `index.html`.

### Android
1. Set up Android SDK paths in **Editor Settings**.
2. Select **Android** preset.
3. Use **One-click Deploy** (top right) or Export APK.

## Running Tests
Run the game from the editor. Press `F6` to run individual scenes or `F5` for the main game.
The automated test runner is available at `res://scenes/testing/TestRunner.tscn`.
