#!/usr/bin/env python3
"""
Level Balance Analyzer — Automated Pre-Flight QA for Definitely Normal Physics
Scans all 24 JSON levels and reports balance, structural, and reachability issues.
"""

import json
import os
import sys
import math

# ─── Configuration ───────────────────────────────────────────────────────────

LEVELS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 
                          "..", "..", "levels", "json")

# Physics constants matching PlayerController.gd
MAX_JUMP_HEIGHT = 200   # Approximate max jump height in pixels
MAX_JUMP_DISTANCE = 400 # Approximate max horizontal jump distance
PLAYER_SIZE = 32        # Player collision height

# Valid physics states (must match PhysicsManager registered states)
VALID_PHYSICS_STATES = [
    "Normal", "LowGravity", "HighGravity", "ReverseGravity",
    "ZeroFriction", "SuperFriction", "BouncyPhysics",
    "SlowMotion", "FastForward", "TeleportJump", "DoubleJump",
    "InvertedControls", "DelayedInput", "RandomDirection",
    "SizeChange", "Underwater", "WindForce", "PhaseThrough",
    "MagnetPlatforms", "WallWalk"
]

# ─── Validation Functions ────────────────────────────────────────────────────

def validate_structure(data, filename):
    """Check required fields and data types."""
    issues = []
    
    required = ["level_id", "player_spawn", "platforms", "exit"]
    for field in required:
        if field not in data:
            issues.append(f"❌ CRITICAL: Missing required field '{field}'")
    
    if "player_spawn" in data:
        spawn = data["player_spawn"]
        if not isinstance(spawn, list) or len(spawn) != 2:
            issues.append("❌ player_spawn must be [x, y]")
    
    if "exit" in data:
        if "position" not in data["exit"]:
            issues.append("❌ exit must have 'position' field")
    
    if "platforms" in data:
        if not isinstance(data["platforms"], list) or len(data["platforms"]) == 0:
            issues.append("❌ Must have at least one platform")
    
    return issues


def analyze_platform_gaps(data):
    """Check if any platform gaps are too wide to jump."""
    issues = []
    platforms = data.get("platforms", [])
    
    if len(platforms) < 2:
        return issues
    
    # Sort platforms by x position
    sorted_platforms = sorted(platforms, key=lambda p: p["position"][0])
    
    for i in range(len(sorted_platforms) - 1):
        p1 = sorted_platforms[i]
        p2 = sorted_platforms[i + 1]
        
        p1_right = p1["position"][0] + p1["size"][0]
        p2_left = p2["position"][0]
        
        gap = p2_left - p1_right
        height_diff = abs(p1["position"][1] - p2["position"][1])
        
        # Account for height difference (higher target = harder jump)
        effective_gap = gap
        if p2["position"][1] < p1["position"][1]:  # Jumping up
            effective_gap += height_diff * 0.5
        
        if effective_gap > MAX_JUMP_DISTANCE:
            issues.append(
                f"⚠️  Large gap ({gap}px) between platforms at "
                f"x={p1_right} and x={p2_left} (height diff: {height_diff}px)"
            )
    
    return issues


def analyze_hazard_density(data):
    """Check for excessive hazard clustering."""
    issues = []
    hazards = data.get("hazards", [])
    
    if len(hazards) < 3:
        return issues
    
    # Check for clusters (3+ hazards within 200px)
    for i, h1 in enumerate(hazards):
        nearby = 0
        for j, h2 in enumerate(hazards):
            if i != j:
                dist = abs(h1["position"][0] - h2["position"][0])
                if dist < 200:
                    nearby += 1
        
        if nearby >= 4:
            issues.append(
                f"⚠️  Hazard cluster ({nearby+1} hazards) near x={h1['position'][0]}"
            )
            break  # Only report once per level
    
    return issues


def analyze_checkpoint_spacing(data):
    """Check for long stretches without checkpoints."""
    issues = []
    checkpoints = data.get("checkpoints", [])
    spawn = data.get("player_spawn", [0, 0])
    exit_pos = data.get("exit", {}).get("position", [0, 0])
    
    # Create list of safe points (spawn + checkpoints + exit)
    safe_points = [spawn[0]]
    for cp in checkpoints:
        safe_points.append(cp["position"][0])
    safe_points.append(exit_pos[0])
    safe_points.sort()
    
    for i in range(len(safe_points) - 1):
        distance = safe_points[i + 1] - safe_points[i]
        if distance > 800:
            issues.append(
                f"⚠️  No checkpoint for {distance}px (x={safe_points[i]} → x={safe_points[i+1]})"
            )
    
    return issues


def analyze_spawn_safety(data):
    """Check if player spawns inside a hazard."""
    issues = []
    spawn = data.get("player_spawn", [0, 0])
    hazards = data.get("hazards", [])
    
    for hazard in hazards:
        hx, hy = hazard["position"]
        dist = math.sqrt((spawn[0] - hx)**2 + (spawn[1] - hy)**2)
        if dist < 50:
            issues.append(
                f"❌ CRITICAL: Player spawns near hazard at ({hx}, {hy})!"
            )
    
    return issues


def analyze_exit_reachability(data):
    """Check if exit has a platform nearby."""
    issues = []
    exit_pos = data.get("exit", {}).get("position", None)
    if not exit_pos:
        return issues
    
    platforms = data.get("platforms", [])
    
    min_dist = float("inf")
    for p in platforms:
        px, py = p["position"]
        pw = p["size"][0]
        
        # Distance from exit to nearest platform edge
        dist_x = max(0, exit_pos[0] - (px + pw), px - exit_pos[0])
        dist_y = abs(exit_pos[1] - py)
        dist = math.sqrt(dist_x**2 + dist_y**2)
        min_dist = min(min_dist, dist)
    
    if min_dist > 300:
        issues.append(
            f"⚠️  Exit at ({exit_pos[0]}, {exit_pos[1]}) is {min_dist:.0f}px from nearest platform"
        )
    
    return issues


def analyze_physics_triggers(data):
    """Validate physics trigger states."""
    issues = []
    triggers = data.get("physics_triggers", [])
    
    for trigger in triggers:
        state = trigger.get("state", "")
        if state not in VALID_PHYSICS_STATES:
            issues.append(f"❌ Unknown physics state in trigger: '{state}'")
    
    return issues


def calculate_difficulty_score(data):
    """Calculate a difficulty score for the level (0-100)."""
    hazard_count = len(data.get("hazards", []))
    trigger_count = len(data.get("physics_triggers", []))
    checkpoint_count = len(data.get("checkpoints", []))
    platform_count = len(data.get("platforms", []))
    
    # More hazards + triggers = harder; more checkpoints + platforms = easier
    difficulty = (hazard_count * 5 + trigger_count * 3) - (checkpoint_count * 8 + platform_count * 1)
    return max(0, min(100, difficulty + 30))  # Normalize to 0-100


# ─── Main Analysis ───────────────────────────────────────────────────────────

def analyze_level(filepath):
    """Run all analyses on a single level file."""
    with open(filepath, 'r') as f:
        data = json.load(f)
    
    filename = os.path.basename(filepath)
    all_issues = []
    
    all_issues.extend(validate_structure(data, filename))
    all_issues.extend(analyze_platform_gaps(data))
    all_issues.extend(analyze_hazard_density(data))
    all_issues.extend(analyze_checkpoint_spacing(data))
    all_issues.extend(analyze_spawn_safety(data))
    all_issues.extend(analyze_exit_reachability(data))
    all_issues.extend(analyze_physics_triggers(data))
    
    difficulty = calculate_difficulty_score(data)
    
    return {
        "filename": filename,
        "title": data.get("title", "Unknown"),
        "issues": all_issues,
        "difficulty": difficulty,
        "stats": {
            "platforms": len(data.get("platforms", [])),
            "hazards": len(data.get("hazards", [])),
            "triggers": len(data.get("physics_triggers", [])),
            "checkpoints": len(data.get("checkpoints", [])),
        }
    }


def main():
    levels_dir = os.path.normpath(LEVELS_DIR)
    
    if not os.path.isdir(levels_dir):
        print(f"Error: Levels directory not found: {levels_dir}")
        sys.exit(1)
    
    files = sorted([f for f in os.listdir(levels_dir) 
                     if f.startswith("world_") and f.endswith(".json")])
    
    if not files:
        print("No level files found!")
        sys.exit(1)
    
    print("=" * 70)
    print("  LEVEL BALANCE ANALYZER — Definitely Normal Physics")
    print("=" * 70)
    print()
    
    total_issues = 0
    critical_count = 0
    warning_count = 0
    results = []
    
    for f in files:
        result = analyze_level(os.path.join(levels_dir, f))
        results.append(result)
        
        criticals = [i for i in result["issues"] if "CRITICAL" in i]
        warnings = [i for i in result["issues"] if "⚠️" in i]
        
        critical_count += len(criticals)
        warning_count += len(warnings)
        total_issues += len(result["issues"])
        
        # Print per-level summary
        status = "✅" if not result["issues"] else ("❌" if criticals else "⚠️")
        stats = result["stats"]
        print(f"{status} {result['filename']:35s} | Diff: {result['difficulty']:3d}/100 "
              f"| P:{stats['platforms']:2d} H:{stats['hazards']:2d} "
              f"T:{stats['triggers']:2d} C:{stats['checkpoints']:2d}")
        
        for issue in result["issues"]:
            print(f"   {issue}")
    
    # ─── Difficulty Curve Analysis ──────────────────────────────────────────
    print()
    print("=" * 70)
    print("  DIFFICULTY CURVE")
    print("=" * 70)
    print()
    
    for world in range(1, 4):
        world_levels = [r for r in results if r["filename"].startswith(f"world_{world:02d}")]
        if world_levels:
            diffs = [l["difficulty"] for l in world_levels]
            print(f"  World {world}: ", end="")
            for i, d in enumerate(diffs):
                bar = "█" * (d // 5)
                print(f"L{i+1}:{d:3d} {bar}")
                if i < len(diffs) - 1:
                    print("           ", end="")
            
            # Check if difficulty is non-monotonic
            inversions = 0
            for i in range(len(diffs) - 1):
                if diffs[i+1] < diffs[i] - 10:
                    inversions += 1
            
            if inversions > 2:
                print(f"  ⚠️  World {world}: Difficulty curve has {inversions} inversions (dips)")
            print()
    
    # ─── Summary ────────────────────────────────────────────────────────────
    print("=" * 70)
    print("  SUMMARY")
    print("=" * 70)
    print(f"  Total levels analyzed: {len(results)}")
    print(f"  Critical issues:       {critical_count}")
    print(f"  Warnings:              {warning_count}")
    print(f"  Passed clean:          {len(results) - len([r for r in results if r['issues']])}")
    print()
    
    if critical_count > 0:
        print("  ❌ RESULT: Critical issues found! Fix before release.")
    elif warning_count > 0:
        print("  ⚠️  RESULT: Warnings found. Review recommended but not blocking.")
    else:
        print("  ✅ RESULT: All levels passed! Ready for manual playtesting.")
    
    print()
    return 1 if critical_count > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
