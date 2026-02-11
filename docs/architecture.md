# System Architecture

## Core Philosophy: The Event-driven State Machine

The game is built around decoupled systems communicating via a global `EventBus`. This avoids spaghetti dependencies (e.g., the Player doesn't know the HUD exists).

### 1. Physics State Pattern
The core mechanic is handled by the **Strategy Pattern**. The `PhysicsManager` holds a reference to the `current_state` (which extends `PhysicsState`).

- **Base Class:** `PhysicsState` (defines default behaviour).
- **Subclasses:** `LowGravity`, `HighGravity`, `ReverseGravity`, `ZeroFriction`, etc.
- **Logic:** `PlayerController` queries `PhysicsManager.current_state` every frame to modify velocity:
  ```gdscript
  # PlayerController.gd
  velocity += PhysicsManager.get_current_gravity() * delta
  ```

### 2. Level Loading System
Levels are defined in **JSON** for easy editing and potential modding, decoupled from `.tscn` scenes.

- **Source of Truth:** `levels/json/*.json`
- **Loader:** `LevelLoader.gd` parses JSON and constructs the runtime node tree.
- **Manager:** `LevelManager.gd` handles progression, loading, and persistence.

**Data Flow:**
1. `LevelManager.load_level(1, 3)`
2. Check for `levels/world_01_level_03.json`
3. `LevelLoader` parses JSON -> instantiates TileMap, Player, Triggers
4. `SceneTransition` fades out -> swaps scene -> fades in.

### 3. Global Signals (EventBus)
All major game events are broadcast via `EventBus` autoload.

| Signal | Source | Listeners |
| :--- | :--- | :--- |
| `physics_changed` | Trigger / Manager | Player, HUD, Audio, Analytics |
| `player_died` | Player | LevelManager, DeathScreen, Analytics |
| `level_complete` | Trigger (End) | LevelManager, SaveManager, UI |
| `death_count_updated` | LevelManager | HUD, Analytics |

### 4. Game Loop
1. **Input:** `PlayerController` reads input (processed by `PhysicsState` logic).
2. **Physics:** `_physics_process` applies forces based on current state.
3. **Collision:** Triggers detect player -> `PhysicsManager.change_state()`.
4. **Visuals:** `ScreenEffects` autoload handles shake/flash/zoom on signals.
5. **UI:** `HUD` updates labels on signals.

### 5. Persistence
`SaveManager` handles local storage (`user://savegame.save`).
- **Settings:** Volume, Analytics opt-in.
- **Progress:** Completed levels, Stars collected.
- **Stats:** Total deaths, Time played.
