# Monetization Strategy — Definitely Normal Physics

## Revenue Model: "Generous Free-to-Play"

The game is **free** with optional non-intrusive monetization. The core gameplay
is never gated. Players should feel rewarded, not punished.

---

## 1. Ad Strategy (Primary Revenue)

### Rewarded Video Ads
- **When:** After death #10+ on a single level, offer "Watch an ad to get a hint"
- **What hint:** Show a ghost replay of the optimal path for 5 seconds
- **Frequency cap:** Max 1 rewarded ad per 5 minutes
- **Player benefit:** They feel in control — ads are optional, not forced

### Interstitial Ads
- **When:** Only between **world transitions** (e.g., completing World 1 → World 2)
- **NOT between individual levels** — this kills engagement
- **Skip timer:** 5 seconds max
- **Frequency:** Max 3 per session

### Banner Ads
- **Where:** Level Select screen only (bottom of screen)
- **NOT during gameplay** — banners during play are unacceptable
- **Format:** Standard 320×50 banner

### Ad SDK Recommendations
| Platform | SDK | Notes |
|----------|-----|-------|
| Mobile | AdMob | Best fill rates, easy Godot plugin |
| Web | Google AdSense | For itch.io / web builds |
| Cross-platform | Unity Ads | Good CPMs, simple integration |

---

## 2. In-App Purchases (Secondary Revenue)

### Cosmetic Items (Non-Gameplay Affecting)
| Item | Price | Description |
|------|-------|-------------|
| Player Skins | $0.99 | Cube → Sphere, Triangle, Star, etc. |
| Trail Effects | $0.99 | Particle trails (fire, ice, rainbow, glitch) |
| Death Animations | $0.99 | Custom shatter effects |
| Skin Bundle | $2.99 | 5 skins + 3 trails (40% discount) |

### Premium Purchases
| Item | Price | Description |
|------|-------|-------------|
| Remove Ads | $2.99 | One-time purchase, removes ALL ads forever |
| World 4 DLC | $1.99 | 8 expert-level stages with new physics states |
| Soundtrack | $0.99 | Download the OST (if original music is created) |

### Pricing Philosophy
- **No pay-to-win.** Cosmetics only.
- **No loot boxes.** Direct purchase.
- **No energy systems.** Play unlimited.
- **No consumables.** One-time purchases only.

---

## 3. Implementation Plan

### Phase 1: Ads (Post-Launch Week 2)
1. Integrate AdMob plugin for Godot
2. Add rewarded ad hook in `DeathScreen.gd` (after 10+ deaths)
3. Add interstitial hook in `LevelManager.gd` (on world change)
4. Add banner to `LevelSelectScreen.gd`

### Phase 2: IAP (Post-Launch Week 4)
1. Integrate Google Play Billing / Apple StoreKit
2. Create `StoreManager.gd` autoload
3. Build cosmetic shop UI
4. Implement skin system in `PlayerController.gd`

### Phase 3: Premium Content (Month 2+)
1. Design World 4 levels
2. Create new physics states for DLC
3. Package and price DLC

---

## 4. Revenue Projections (Conservative)

| Metric | Estimate |
|--------|----------|
| DAU (Month 1) | 500-1,000 |
| Ad Revenue (CPM $2) | $30-60/month |
| IAP Conversion | 2-3% of users |
| IAP Revenue | $50-150/month |
| Remove Ads Revenue | $100-300/month |

**Break-even target:** $0 (hobby project — any revenue is a bonus)

---

## 5. Ethical Guardrails

- ✅ No dark patterns (no "Are you SURE you don't want this deal?")
- ✅ No artificial difficulty spikes before ad prompts
- ✅ No PII collection for ad targeting
- ✅ COPPA compliant (no age-gated content)
- ✅ GDPR compliant (analytics opt-out in settings)
- ✅ Full game accessible without spending money
