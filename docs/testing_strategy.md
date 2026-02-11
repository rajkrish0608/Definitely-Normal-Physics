# Definitely Normal Physics — Testing & Optimization Strategy

## 1. Automated Test Suite

### Test Runner (`scripts/testing/TestRunner.gd`)
Attach to a standalone scene and run from the Godot editor. Tests cover:

| System | Tests | What's Verified |
|---|---|---|
| PhysicsManager | 7 | Default state, transitions, gravity direction, push/pop stack, invalid states, friction, bounce |
| SaveManager | 4 | Set/get settings, missing keys, level completion saves, reset progress |
| LevelManager | 6 | Star calculation at boundaries (0, 5, 6, 10, 11, 100 deaths) |
| EventBus | 2 | Signal existence, emission and reception |

**How to run:**
1. Create a new scene in Godot with a single `Node` root.
2. Attach `scripts/testing/TestRunner.gd` to it.
3. Run the scene (F6). Check the Output panel.

---

## 2. Level Validation Checklist

For each of the 24 levels, verify:

- [ ] Level loads without JSON parse errors
- [ ] Player spawns at the correct position
- [ ] All platforms are reachable
- [ ] All hazards are avoidable with skill
- [ ] Physics triggers activate correctly
- [ ] Checkpoints save/restore position
- [ ] Exit is reachable and triggers completion
- [ ] Star ratings: ≤5 deaths = 3★, ≤10 = 2★, 11+ = 1★
- [ ] No softlocks (player can't get permanently stuck)

---

## 3. Performance Monitoring

### PerformanceMonitor (`scripts/testing/PerformanceMonitor.gd`)
Add as a child CanvasLayer to any scene. Displays:
- FPS (green/yellow/red based on thresholds)
- Frame time in ms
- Memory usage
- Node/object counts
- Orphan node count (leak detection)
- Draw calls per frame

### Target Metrics

| Platform | Target FPS | Max Frame Time | Max Memory |
|---|---|---|---|
| Desktop | 60 | 16.6ms | 512 MB |
| Mobile | 60 | 16.6ms | 256 MB |
| Web | 60 | 16.6ms | 256 MB |

### Optimization Checklist

- [ ] Object pooling enabled in LevelLoader ✅
- [ ] No orphan nodes after level transitions
- [ ] Physics triggers disable after one_time activation
- [ ] SFX pool reuses AudioStreamPlayers
- [ ] Screen effects clean up Tweens properly
- [ ] No excessive `_process()` calls on invisible UI
- [ ] Camera shake uses single Tween, not per-frame random
- [ ] JSON levels are parsed once and cached

---

## 4. Platform-Specific Testing

### Desktop (macOS/Windows/Linux)
- [ ] Keyboard + gamepad input works
- [ ] Window resize doesn't break UI
- [ ] Fullscreen toggle works
- [ ] Save file persists between sessions

### Mobile (iOS/Android)
- [ ] Touch controls visible and responsive
- [ ] Touch controls hide on desktop
- [ ] UI elements are finger-sized (≥48px)
- [ ] No lag on physics triggers
- [ ] Battery usage is reasonable

### Web (HTML5)
- [ ] Initial load time < 5 seconds
- [ ] Audio plays after first user interaction
- [ ] No WebGL errors in console
- [ ] Save data persists (IndexedDB)

---

## 5. Difficulty Balance Targets

| World | Deaths per level (median) | Completion time (target) |
|---|---|---|
| World 1 (Tutorial) | 3–8 | 30–60 seconds |
| World 2 (Advanced) | 8–15 | 45–90 seconds |
| World 3 (Expert) | 15–30 | 60–120 seconds |

3-star should feel challenging but achievable on 2nd-3rd attempt.
