# QA Edge-Case Test Scenarios

This document contains a comprehensive list of edge-case scenarios to test before release. Each test validates that the game handles unusual or edge-case inputs gracefully.

---

## 🎮 Player Mechanics

### PM-01: Rapid Input Spam
**Scenario:** Player mashes jump button repeatedly while in air  
**Expected:** Only first jump triggers. No double/triple jumps. Input queue doesn't overflow.  
**Test:** Hold Space for 2 seconds. Verify single jump only.

### PM-02: Simultaneous Opposite Inputs
**Scenario:** Player presses Left + Right simultaneously  
**Expected:** Player stops moving (inputs cancel out) OR one takes priority consistently.  
**Test:** Press `A` + `D` together. Player should not glitch or move unpredictably.

### PM-03: Frame-Perfect Landing
**Scenario:** Player lands on platform edge (1-pixel overlap)  
**Expected:** Registers as landing. No fall-through.  
**Test:** Create thin platform. Jump onto edge. Should land, not clip through.

### PM-04: Death During Physics Change
**Scenario:** Player hits spike while physics state is changing  
**Expected:** Death triggers normally. No crash. Physics change cancels cleanly.  
**Test:** Place spike inside a physics trigger. Walk through. Die. Respawn should work.

### PM-05: Input Delay Queue Overflow
**Scenario:** In a level with 2s input delay, spam 100 inputs  
**Expected:** Queue caps at reasonable size (e.g., 10 inputs). Old inputs dropped. No memory leak.  
**Test:** Enable input delay. Mash WASD for 10 seconds. Check memory usage.

---

## 🌀 Physics States

### PS-01: Rapid State Transitions
**Scenario:**  Place 5 physics triggers in a row (Normal → Low-G → High-G → Reverse → Bouncy)  
**Expected:** All states apply correctly in sequence. No state "sticks

" after leaving trigger.  
**Test:** Walk through chain of triggers. Verify each state activates and deactivates.

### PS-02: Nested Triggers
**Scenario:** Reverse Gravity trigger contains a smaller Low Gravity trigger  
**Expected:** Inner trigger overrides outer. Exiting inner restores outer, not Normal.  
**Test:** Create nested triggers. Walk in → inner → out. Verify state stack.

### PS-03: Bounce on Ceiling (Reverse Gravity)
**Scenario:** Player in Reverse Gravity jumps and "lands" on ceiling while Bouncy state active  
**Expected:** Bounces off ceiling correctly (upward in screen space).  
**Test:** Reverse gravity + bouncy. Jump to ceiling. Should bounce.

### PS-04: Zero Friction + High Speed
**Scenario:** Player accelerates to max speed, enters Zero Friction zone  
**Expected:** Slides at constant velocity. No infinite acceleration. Eventually stops at walls.  
**Test:** Run full speed → hit ice. Should slide but not accelerate indefinitely.

### PS-05: State Change Mid-Jump
**Scenario:** Player jumps in Normal state, passes through High Gravity trigger mid-air  
**Expected:** Jump arc changes immediately. Player falls faster.  
**Test:** Place trigger at jump apex. Verify gravity increases mid-jump.

---

## 💀 Death & Respawn

### DR-01: Instant Death Loop
**Scenario:** Checkpoint placed on top of a spike  
**Expected:** Player respawns at checkpoint, immediately dies, respawns again (death loop). **NO CRASH.**  
**Test:** Set checkpoint = death zone. Should loop deaths gracefully.

### DR-02: Fall-Off Death at Exact Y-Limit
**Scenario:** Player position.y == DEATH_FALL_Y (exactly at boundary)  
**Expected:** Death triggers. No float comparison issues.  
**Test:** Set DEATH_FALL_Y = 1000. Debug print player.y. Verify death at y >= 1000.

### DR-03: Respawn During Scene Transition
**Scenario:** Player dies while level complete screen is fading in  
**Expected:** Respawn cancels OR scene transition takes priority (no softlock).  
**Test:** Walk into exit and spike at same time. Should not softlock.

### DR-04: Death Counter Overflow
**Scenario:** Player accumulates 10,000+ deaths on one level  
**Expected:** Counter displays correctly. No integer overflow. UI doesn't break.  
**Test:** Manually set death\_count = 99999. Check if UI still renders.

---

## 📦 Level Management

### LM-01: Load Non-Existent Level
**Scenario:** Call `LevelManager.load_level(99, 99)`  
**Expected:** Error logged gracefully. Returns to level select OR shows error screen. **NO CRASH.**  
**Test:** Add debug button to load invalid level. Should handle gracefully.

### LM-02: Complete Level Twice
**Scenario:** Reach exit, trigger level\_complete, quickly touch exit again before scene loads  
**Expected:** Event fires once. No duplicate star save. No double scene transition.  
**Test:** Spam exit trigger. Should only count once.

### LM-03: JSON Level Missing Required Fields
**Scenario:** JSON file missing `"exit"` or `"start_position"`  
**Expected:** LevelLoader logs error. Provides default values OR refuses to load (safe fail).  
**Test:** Remove `"exit"` from JSON. Load level. Should not crash.

### LM-04: Checkpoint After Level Complete
**Scenario:** Player reaches exit, then touches checkpoint during fade-out  
**Expected:** Checkpoint ignored (level already complete). No checkpoint saved for next attempt.  
**Test:** Place checkpoint near exit. Complete level. Touch checkpoint. Shouldn't save.

---

## 🎨 UI & Menus

### UI-01: Pause During Death Animation
**Scenario:** Player dies, presses ESC during death animation  
**Expected:** Pause menu opens OR is blocked during death. No UI stack corruption.  
**Test:** Die → immediately press ESC. Verify behavior is consistent.

### UI-02: Rapid Button Mashing
**Scenario:** Player clicks "Retry" button 10 times in 0.5 seconds  
**Expected:** Level restarts once. Button becomes unresponsive after first click.  
**Test:** Spam-click retry. Should load level once only.

### UI-03: Settings Changed Mid-Level
**Scenario:** Player pauses, mutes music, resumes  
**Expected:** Music stops immediately. Settings persist after unpause.  
**Test:** Play level → Pause → Mute → Resume. Music should stay muted.

### UI-04: HUD Timer Overflow
**Scenario:** Player stays in level for 1+ hour  
**Expected:** Timer displays 60:00+ correctly. No overflow. Timer doesn't reset to 00:00.  
**Test:** Manually set `level_timer = 3661.0`. Check if HUD shows "61:01".

---

## 💾 Save System

### SV-01: Save File Corruption
**Scenario:** Manually corrupt `user://savegame.save` (add invalid JSON)  
**Expected:** Game detects corruption. Deletes save OR creates new one. Logs warning. **NO CRASH.**  
**Test:** Edit save file to be invalid. Launch game. Should handle gracefully.

### SV-02: Save During Level Load
**Scenario:** Trigger save (e.g., complete level) while next level is loading  
**Expected:** Save completes before scene change OR is queued. No data loss.  
**Test:** Complete level → immediately alt+F4. Relaunch. Stars should be saved.

### SV-03: Negative Star Count
**Scenario:** Manually edit save file to set `"stars": -5`  
**Expected:** Game clamps to 0. Level select shows 0 stars. No UI rendering issues.  
**Test:** Edit save. Load game. Check level select.

---

## 🎵 Audio

### AU-01: Play 100 SFX Simultaneously
**Scenario:** Trigger 100 death sounds in 0.1 seconds (particle collisions, multi-kill)  
**Expected:** SFX pool limits concurrent sounds. No audio distortion or crash.  
**Test:** Create 100 spikes. Die while touching all. Should not crash.

### AU-02: Volume Set to 0 Before Sound Plays
**Scenario:** Mute SFX → trigger SFX → unmute  
**Expected:** No sound plays while muted. Unmuting doesn't retroactively play queued sounds.  
**Test:** Mute → Jump → Unmute. Jump SFX should not play.

---

## 📊 Analytics

### AN-01: Event Queue Overflow (Offline)
**Scenario:** Play 1000 levels with no internet connection  
**Expected:** Analytics queues events locally. File size caps at reasonable limit (e.g., 10MB). Old events dropped.  
**Test:** Disconnect internet. Play 50 levels. Check cache size: `user://analytics_cache.json`.

### AN-02: Opt-Out Mid-Session
**Scenario:** Player opts out of analytics in settings  
**Expected:** All cached events deleted immediately. No further tracking.  
**Test:** Play → Generate events → Opt out → Check cache file (should be deleted).

---

## 🔌 Edge-Case Combos

### EC-01: Reverse Gravity + Zero Friction + Bouncy + High Speed
**Scenario:** All modifiers active at once  
**Expected:** Player behaves predictably (slides upward, bounces off ceiling, slippery).  
**Test:** Stack all triggers. Should not crash or behave chaotically.

### EC-02: One-Time Trigger Re-Enter
**Scenario:** Trigger set to `one_time=true`. Player enters, exits, re-enters.  
**Expected:** Trigger does NOT fire second time.  
**Test:** Create one-time trigger. Walk through twice. Should only activate once.

### EC-03: End of World Transition
**Scenario:** Complete World 3, Level 8 (final level)  
**Expected:** Returns to level select. No attempt to load World 4.  
**Test:** Beat final level. Should show level select, not crash.

---

## ✅ Test Completion Checklist

Use this checklist to track QA progress:

- [ ] **Player Mechanics (PM-01 to PM-05):** 0/5 passed
- [ ] **Physics States (PS-01 to PS-05):** 0/5 passed
- [ ] **Death & Respawn (DR-01 to DR-04):** 0/4 passed
- [ ] **Level Management (LM-01 to LM-04):** 0/4 passed
- [ ] **UI & Menus (UI-01 to UI-04):** 0/4 passed
- [ ] **Save System (SV-01 to SV-03):** 0/3 passed
- [ ] **Audio (AU-01 to AU-02):** 0/2 passed
- [ ] **Analytics (AN-01 to AN-02):** 0/2 passed
- [ ] **Edge-Case Combos (EC-01 to EC-03):** 0/3 passed

**Total:** 0/32 tests passed
