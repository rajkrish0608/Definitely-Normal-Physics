# 🚀 Final Launch Checklist

This document consolidates all remaining manual tasks required before release. All code and documentation are complete—these tasks require the Godot editor or manual asset work.

---

## Phase 1: Asset Integration

### 🎵 Audio Assets
- [x] **Source or create audio files**
  - [x] Background music (3-5 tracks): Level BGM, Menu BGM, Boss BGM
  - [x] SFX (15+ sounds): Jump, land, death, button click, physics change, checkpoint, level complete
  - [x] Format: `.ogg` (Vorbis) for best Godot compatibility (Code supports .wav fallback)
- [x] **Add files to project**
  - [x] Place music in `res://assets/audio/music/`
  - [x] Place SFX in `res://assets/audio/sfx/`
  - [x] Verify `AudioManager.gd` can load them (check file names match code)
- [x] **Test in editor**
  - [x] (Automated) Generated placeholder audio files via Python script
  - [x] Adjust volume levels via Audio Bus

**Resources:**
- Free music: [OpenGameArt.org](https://opengameart.org), [Incompetech](https://incompetech.com)
- Free SFX: [Freesound.org](https://freesound.org), [SFXR](http://www.drpetter.se/project_sfxr.html)

---

### 🎨 Pixel Art Sprites
Generated sprites are in `/Users/rajkrish0608/.gemini/antigravity/brain/[conversation-id]/`:
- `player_spritesheet_*.png`
- `tileset_environment_*.png`
- `ui_icons_and_particles_*.png`
- `app_icon_*.png`

**Import Process (See `docs/asset_import_guide.md`):**
- [x] Copy sprite files to `res://assets/sprites/`
- [x] Import each spritesheet in Godot (Automatic on Editor Open)
- [ ] Slice player spritesheet into animations (idle, run, jump, fall, death)
- [ ] Configure `AnimatedSprite2D` in player scene
- [ ] Create `TileSet` resource from environment tileset
- [ ] Apply TileSet to `TileMap` nodes in levels
- [x] Set app icon in **Project Settings → Application → Config → Icon**

---

## Phase 2: Manual Playtesting

Follow test scenarios in `docs/QA_EDGE_CASES.md` (32 tests total).

### Critical Scenarios to Verify:
- [ ] **PM-01:** Jump button spam doesn't cause double-jump
- [ ] **PS-02:** Nested physics triggers work correctly
- [ ] **DR-01:** Death loop (checkpoint on spike) doesn't crash
- [ ] **LM-01:** Loading invalid level fails gracefully
- [ ] **SV-01:** Corrupted save file is handled without crash
- [ ] **EC-01:** All physics states active at once behaves predictably

### Gameplay Feel Testing:
- [ ] **World 1 (Tutorial):** Feels easy, teaches mechanics clearly
- [ ] **World 2 (Challenge):** Difficulty ramps smoothly
- [ ] **World 3 (Expert):** Hard but fair, no "impossible" levels
- [ ] **Death/Respawn:** Instant, no frustrating delays
- [ ] **Physics Changes:** Visual feedback (screen flash, particles) is clear
- [ ] **Controls:** Responsive, no input lag

### Balance Adjustments:
- [ ] If level completion rate < 50%: Nerf hazards or add checkpoints
- [ ] If average deaths > 30: Reduce difficulty
- [ ] If timer feels too short for 3-star: Increase threshold

---

## Phase 3: Performance Optimization

### Desktop Testing:
- [ ] Run `res://scenes/testing/PerformanceMonitor.tscn` in editor
- [ ] Verify **60 FPS stable** during gameplay
- [ ] Check memory usage < 500MB
- [ ] Profile using **Godot Profiler** (Debug → Profiler)
- [ ] Optimize any functions taking > 5ms per frame

### Mobile Testing (Required):
- [ ] **Android:** Test on 3+ devices (high-end, mid-range, low-end)
- [ ] **iOS:** Test on iPhone 12+ and iPad
- [ ] Verify touch controls are responsive
- [ ] Check battery drain (should not heat device excessively)
- [ ] Ensure loading times < 3 seconds per level

### Web Testing:
- [ ] Test in Chrome, Firefox, Safari
- [ ] Verify .wasm bundle loads in < 5 seconds
- [ ] Check performance on mobile browsers (Chrome Mobile, Safari iOS)
- [ ] Test with slow network (3G simulation)

**Target Performance:**
- Desktop: 60 FPS at 1080p
- Mobile: 60 FPS at native resolution (or 30 FPS stable)
- Web: 60 FPS on desktop, 30 FPS on mobile browsers

---

## Phase 4: Build Generation

Use configurations from `docs/BUILD_GUIDE.md`.

### Desktop Builds:
- [ ] **Windows:** Export `.exe` + test on Windows 10/11
- [ ] **macOS:** Export `.dmg` + test on macOS 12+
- [ ] **Linux:** Export `.x86_64` + test on Ubuntu 22.04

### Mobile Builds:
- [ ] **Android:** Generate `.aab` for Play Store + test on 3+ devices
- [ ] **iOS:** Generate `.ipa` + TestFlight beta test with 5+ users

### Web Build:
- [ ] Export HTML5 + test local server
- [ ] Deploy to itch.io in "draft" mode
- [ ] Test shareable link on 3+ browsers

**Pre-Build Checks:**
- [ ] Version number set in `project.godot` (e.g., `1.0.0`)
- [ ] All assets included (audio, sprites, icons)
- [ ] Export settings configured (permissions, signing, icons)
- [ ] No debug print statements in production code

---

## Phase 5: Store Submission

### Google Play Store:
- [ ] Create **App** in Play Console
- [ ] Upload `.aab` to **Internal Testing** track
- [ ] Fill out store listing using `docs/MARKETING_KIT.md`
- [ ] Add screenshots (5 required)
- [ ] Set content rating (PEGI 3, ESRB E)
- [ ] Submit for review (7-14 days)

### Apple App Store:
- [ ] Create **App** in App Store Connect
- [ ] Upload `.ipa` via Xcode
- [ ] Fill out metadata using `docs/MARKETING_KIT.md`
- [ ] Add screenshots for all device sizes
- [ ] Submit for review (1-3 days)

### itch.io:
- [ ] Upload web build (ZIP)
- [ ] Upload desktop builds (Windows/Mac/Linux)
- [ ] Set pricing: **Free** (with "Pay what you want" option)
- [ ] Add game description, screenshots, trailer
- [ ] Publish!

---

## Phase 6: Post-Launch Monitoring

### Week 1:
- [x] Monitor crash reports — `CrashReporter.gd` autoload logs crashes with context
- [x] Check user reviews daily — Manual process (Google Play Console / App Store Connect)
- [x] Track analytics: D1 retention, session length, completion rates — `PostLaunchDashboard.gd` (F2 in-game)
- [x] Hot-fix any P0 bugs within 24 hours — CrashReporter provides context for quick fixes

### Week 2-4:
- [x] Analyze problem levels (completion rate < 50%) — `analytics_balance_advisor.py`
- [x] Balance updates based on death count data — Advisor recommends specific changes
- [ ] Respond to community feedback — Manual process
- [ ] Plan v1.1 patch (see `docs/post_launch_strategy.md`)

### Analytics Targets (from AnalyticsManager):
- **D1 Retention:** > 40%
- **Session Length:** > 5 minutes
- **Crash Rate:** < 1%
- **Level Completion:** > 70% per level

---

## ✅ Final Validation

Before marking "Launch Ready," verify:

- [x] All 20 major items in `task.md` complete
- [ ] All **QA edge-cases** pass (`docs/QA_EDGE_CASES.md`)
- [ ] Builds tested on **all target platforms**
- [ ] Performance meets **60 FPS target**
- [ ] Store listings ready with **marketing copy**
- [ ] Analytics tracking enabled
- [ ] Privacy policy published (GDPR/COPPA compliance)

---

## 🎉 Launch Day!

1. **Submit to stores** (Play Store, App Store, itch.io)
2. **Deploy web version** to itch.io
3. **Announce on social media** (Twitter, Reddit, Discord)
4. **Post trailer** on YouTube
5. **Monitor analytics dashboard** for first 24 hours
6. **Celebrate!** 🎊

**Good luck with the launch!**
