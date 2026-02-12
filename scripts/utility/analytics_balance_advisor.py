#!/usr/bin/env python3
"""
Analytics Balance Advisor — Post-Launch Level Balancing Tool

Reads the analytics cache (user://analytics_cache.json) and suggests
balance adjustments based on death rates and completion times.

Run this after collecting player data to identify problem levels.
"""

import json
import os
import sys
from collections import defaultdict

# Path to analytics cache (copy from device to analyze)
DEFAULT_CACHE_PATH = os.path.expanduser(
    "~/Library/Application Support/Godot/app_userdata/"
    "Definitely Normal Physics/analytics_cache.json"
)

# Thresholds from LAUNCH_CHECKLIST.md
TARGET_COMPLETION_RATE = 0.70  # > 70%
MAX_AVG_DEATHS = 30
TARGET_D1_RETENTION = 0.40

def analyze_analytics(cache_path):
    if not os.path.exists(cache_path):
        print(f"Analytics cache not found at: {cache_path}")
        print("Copy it from your device's user:// directory first.")
        print(f"\nExpected path: {cache_path}")
        return
    
    with open(cache_path, 'r') as f:
        events = json.load(f)
    
    if not events:
        print("No analytics events found.")
        return
    
    # Process events
    level_starts = defaultdict(int)
    level_completes = defaultdict(int)
    level_deaths = defaultdict(list)
    level_times = defaultdict(list)
    sessions = set()
    death_positions = defaultdict(list)
    
    for event in events:
        event_type = event.get("event", "")
        data = event.get("data", {})
        session = event.get("session_id", "unknown")
        sessions.add(session)
        
        level_key = f"W{data.get('world', '?')}-L{data.get('level', '?')}"
        
        if event_type == "level_start":
            level_starts[level_key] += 1
        elif event_type == "level_complete":
            level_completes[level_key] += 1
            if "deaths" in data:
                level_deaths[level_key].append(data["deaths"])
            if "time_seconds" in data:
                level_times[level_key].append(data["time_seconds"])
        elif event_type == "death":
            if "position" in data:
                death_positions[level_key].append(data["position"])
    
    # ─── Report ──────────────────────────────────────────────────────────
    
    print("=" * 60)
    print("  ANALYTICS BALANCE ADVISOR")
    print("=" * 60)
    print(f"\n  Total Events: {len(events)}")
    print(f"  Unique Sessions: {len(sessions)}")
    print(f"  Levels Played: {len(level_starts)}")
    print()
    
    # Per-level analysis
    print(f"{'Level':<10} {'Starts':>7} {'Clears':>7} {'Rate':>7} {'Avg Deaths':>11} {'Status':<10}")
    print("-" * 60)
    
    problem_levels = []
    
    for world in range(1, 4):
        for level in range(1, 9):
            key = f"W{world}-L{level}"
            starts = level_starts.get(key, 0)
            completes = level_completes.get(key, 0)
            
            rate = completes / max(starts, 1)
            avg_deaths = (sum(level_deaths.get(key, [0])) / 
                         max(len(level_deaths.get(key, [1])), 1))
            
            status = "✅"
            suggestion = ""
            
            if starts > 0:
                if rate < TARGET_COMPLETION_RATE:
                    status = "❌ HARD"
                    suggestion = "Reduce hazards or add checkpoint"
                    problem_levels.append((key, rate, avg_deaths, suggestion))
                elif avg_deaths > MAX_AVG_DEATHS:
                    status = "⚠️ GRINDY"
                    suggestion = "Reduce death traps"
                    problem_levels.append((key, rate, avg_deaths, suggestion))
            else:
                status = "—"
            
            if starts > 0:
                print(f"{key:<10} {starts:>7} {completes:>7} {rate:>6.0%} {avg_deaths:>11.1f} {status:<10}")
    
    # ─── Recommendations ──────────────────────────────────────────────
    
    print()
    print("=" * 60)
    print("  RECOMMENDATIONS")
    print("=" * 60)
    
    if problem_levels:
        print()
        for key, rate, deaths, suggestion in problem_levels:
            print(f"  🔧 {key}: {suggestion}")
            print(f"     Completion: {rate:.0%} | Avg Deaths: {deaths:.1f}")
            print()
    else:
        print("\n  ✅ All levels within target thresholds!")
        print(f"     Completion: >{TARGET_COMPLETION_RATE:.0%} | Deaths: <{MAX_AVG_DEATHS}")
    
    # ─── Retention ──────────────────────────────────────────────────────
    
    print()
    print("=" * 60)
    print("  RETENTION ANALYSIS")
    print("=" * 60)
    
    total_sessions = len(sessions)
    w1_players = level_starts.get("W1-L1", 0)
    w1_completers = level_completes.get("W1-L8", 0)
    w2_players = level_starts.get("W2-L1", 0)
    w3_players = level_starts.get("W3-L1", 0)
    
    print(f"\n  Sessions: {total_sessions}")
    print(f"  Started W1: {w1_players}")
    print(f"  Finished W1: {w1_completers} ({w1_completers/max(w1_players,1):.0%})")
    print(f"  Started W2: {w2_players} ({w2_players/max(w1_players,1):.0%} retention)")
    print(f"  Started W3: {w3_players} ({w3_players/max(w1_players,1):.0%} retention)")
    print()


def main():
    cache_path = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_CACHE_PATH
    
    print(f"Reading analytics from: {cache_path}\n")
    
    if not os.path.exists(cache_path):
        # Generate sample data for demonstration
        print("No analytics data found. Generating sample data for demo...\n")
        _generate_sample_data(cache_path)
    
    analyze_analytics(cache_path)


def _generate_sample_data(path):
    """Generate sample analytics data for testing the advisor."""
    import random
    
    events = []
    session_id = "demo-session-001"
    
    for world in range(1, 4):
        for level in range(1, 9):
            # Simulate multiple play attempts
            attempts = random.randint(1, 5)
            for _ in range(attempts):
                events.append({
                    "event": "level_start",
                    "data": {"world": world, "level": level},
                    "session_id": session_id,
                    "timestamp": "2026-02-12T12:00:00"
                })
            
            # Some complete, some don't
            if random.random() < (0.9 - world * 0.15):
                deaths = random.randint(0, 10 * world)
                time_s = random.uniform(20, 120 * world)
                events.append({
                    "event": "level_complete",
                    "data": {
                        "world": world, "level": level,
                        "deaths": deaths, "time_seconds": time_s
                    },
                    "session_id": session_id,
                    "timestamp": "2026-02-12T12:05:00"
                })
    
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        json.dump(events, f, indent=2)
    
    print(f"Sample data written to: {path}\n")


if __name__ == "__main__":
    main()
