# Definitely Normal Physics

A 2D troll platformer built with Godot 4.2 where physics rules change unexpectedly mid-level.

## Features (Implemented)
- **Modular Physics System**: Base state pattern for 20+ physics variations.
- **Physics Manager**: Singleton for state transitions with support for push/pop stacks.
- **Utility Systems**:
  - Global `EventBus` for decoupled communication.
  - `ScreenEffects` for camera shake, flashes, tinting, and slow-motion.
  - `SceneTransition` for smooth fade transitions.
- **Save System**: JSON-based persistent storage for progress and settings.

## Getting Started
1. Install [Godot 4.2](https://godotengine.org/).
2. Clone this repository.
3. Open `project.godot` in the Godot Editor.

## Architecture
The game uses a singleton-heavy architecture centered around an `EventBus` to handle global state changes (like physics shifts) without tight coupling between the Player and the Environment.
