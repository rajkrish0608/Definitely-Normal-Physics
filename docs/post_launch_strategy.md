# Post-Launch Strategy — Definitely Normal Physics

## 1. Launch Week Checklist

### Day 1-3: Soft Launch
- [ ] Deploy to Google Play (Open Testing track)
- [ ] Deploy web build to itch.io
- [ ] Share in 2-3 small communities for initial feedback
- [ ] Monitor crash reports and analytics dashboard
- [ ] Fix any critical P0 bugs immediately

### Day 4-7: Full Launch
- [ ] Promote to Production on Google Play
- [ ] Submit to Apple App Store
- [ ] Post on r/indiegaming, r/playmygame, r/godot
- [ ] Upload trailer to YouTube
- [ ] Tweet/post launch announcement

---

## 2. Community Channels

### Discord Server
- **#general** — Chat and memes
- **#bug-reports** — Structured bug reporting
- **#suggestions** — Feature requests
- **#speedruns** — Time leaderboards and strategies
- **#screenshots** — Player-shared clips

### Reddit
- Create r/DefinitelyNormalPhysics (or post in r/indiegaming)
- Weekly "Physics Challenge" threads

### Social Media
- Twitter/X: @DefNormalPhys — Dev logs, memes, patch notes
- TikTok: Short funny death compilation clips

---

## 3. Analytics-Driven Decisions

### Key Metrics to Monitor
| Metric | Target | Action if Below Target |
|--------|--------|----------------------|
| D1 Retention | >40% | Improve tutorial/onboarding |
| D7 Retention | >15% | Add more content variety |
| Level Completion Rate | >70% per level | Nerf difficult levels |
| Avg. Deaths/Level | <15 (World 1) | Adjust physics values |
| Session Length | >5 min | Add more engagement hooks |
| Crash Rate | <1% | Priority bug fixes |

### Problem Level Detection
If a level has:
- **Completion rate < 50%:** Flag for difficulty review
- **Average deaths > 30:** Consider adding hint system
- **Rage-quit rate > 20%:** Add optional skip after N deaths

### How Analytics Flows
```
EventBus signals → AnalyticsManager → Local JSON cache
                                    → Backend API (optional)
                                    → Dashboard (future)
```

---

## 4. Content Update Roadmap

### Update 1.1 — "Quality of Life" (Week 2-3)
- Fix bugs from launch feedback
- Balance difficulty based on analytics
- Add "Skip Level" option (after 50 deaths)
- Improve tutorial tooltips

### Update 1.2 — "Cosmetic Shop" (Month 1)
- Player skin system
- Trail effects
- Death animation customization
- "Remove Ads" IAP

### Update 2.0 — "World 4: Quantum Chaos" (Month 2)
- 8 new expert levels
- 2 new physics states:
  - **Quantum Tunneling:** Player can phase through thin walls
  - **Time Dilation:** Slow-motion zones
- New boss mechanic: physics states on a timer

### Update 3.0 — "Multiplayer Mayhem" (Month 4+)
- Ghost race mode (asynchronous multiplayer)
- Daily challenge levels (procedurally generated)
- Global leaderboards
- Community-created levels (level editor)

---

## 5. New Physics States (Planned)

| State | Description | Priority |
|-------|-------------|----------|
| Quantum Tunneling | Phase through thin walls | P1 — World 4 |
| Time Dilation | Local slow-motion zones | P1 — World 4 |
| Magnetic Pull | Attract toward metal surfaces | P2 — World 5 |
| Size Shift | Player grows/shrinks | P2 — World 5 |
| Invisible Platforms | Platforms appear on proximity | P3 — Special Event |

---

## 6. Seasonal Content Ideas

| Season | Theme | Content |
|--------|-------|---------|
| Halloween | "Spooky Physics" | Ghost skins, dark levels, invisible platforms |
| Winter | "Frozen Lab" | Ice-heavy levels, snowflake trail, holiday skin |
| April Fools | "Extremely Normal Physics" | Every level is chaos, troll physics everywhere |
| Anniversary | "Lab Report" | Stats summary, exclusive skin, thank-you message |

---

## 7. Long-Term Vision (6-12 Months)

### Level Editor & Community
- In-game level editor with physics trigger placement
- Share levels via codes or community hub
- Featured community levels each week
- "Most Deaths" Hall of Fame

### Platform Expansion
- Steam release with achievements
- Nintendo Switch (if successful on mobile)
- Desktop builds with controller support

### Franchise Potential
- "Definitely Normal Chemistry" — liquid physics puzzle game
- "Definitely Normal Biology" — evolution/mutation platformer
- Shared universe / crossover skins

---

## 8. Support & Maintenance

### Bug Priority Matrix
| Priority | Response Time | Example |
|----------|--------------|---------|
| P0 — Critical | Same day | Crash on launch, data loss |
| P1 — High | 48 hours | Level impossible to complete |
| P2 — Medium | 1 week | Visual glitch, wrong text |
| P3 — Low | Next update | Minor polish, QoL suggestion |

### Deprecation Policy
- Support last 2 major versions
- Minimum OS: Android 8.0, iOS 15
- Drop web support if < 5% of player base
