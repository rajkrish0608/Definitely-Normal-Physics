## GameConstants — Global Gameplay Balances & Configuration (Static Utility)
##
## Centralized location for gameplay constants to allow easy tweaking.
class_name GameConstants
extends RefCounted

# ─── Physics ─────────────────────────────────────────────────────────────────
const GRAVITY_BASE: float = 980.0
const TERMINAL_VELOCITY: float = 2000.0

# ─── Visuals ─────────────────────────────────────────────────────────────────
const TINT_TRANSITION_TIME: float = 0.4
const CAM_SHAKE_DEFAULT_INTENSITY: float = 10.0
const CAM_SHAKE_DEFAULT_DURATION: float = 0.2

# ─── Logic ───────────────────────────────────────────────────────────────────
const STAR_3_DEATH_LIMIT: int = 5
const STAR_2_DEATH_LIMIT: int = 10
const COYOTE_TIME: float = 0.15
