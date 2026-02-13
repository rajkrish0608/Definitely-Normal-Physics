# 🤖 Automated E2E Test Suite

## Quick Start

### Run Tests in Godot Editor

1. **Open Godot**
2. **In the FileSystem panel**, navigate to: `scenes/testing/E2ETestRunner.tscn`
3. **Right-click** the file → **"Run Scene"** (or press **F6** with the file selected)
4. **Watch the Output panel** for test results

### What Gets Tested

The test suite runs 8 comprehensive tests:

1. ✅ **Level Loading** - Verifies levels load from JSON
2. ✅ **Player Spawn** - Checks player appears at spawn point
3. ✅ **Horizontal Movement** - Tests A/D movement controls
4. ✅ **Jump Mechanics** - Verifies jump height and physics
5. ✅ **Gravity Physics** - Confirms player falls correctly
6. ✅ **Physics State Changes** - Tests state switching (Normal → LowGravity)
7. ✅ **Collision Detection** - Validates platform collisions
8. ✅ **Death & Respawn** - Checks death trigger and respawn

### Reading Test Output

```
🧪 Testing: Player Jump Mechanics...
   ✅ PASS: Player jumped: 87.3 pixels height (0.35s)
```

Each test shows:
- **Test name** being run
- **✅ PASS** or **❌ FAIL** status
- **Details** about what was tested
- **Duration** in seconds

### Final Report

After all tests complete, you'll see:

```
📊 TEST REPORT
═══════════════════════════════════════════════════════════
Summary:
  Total Tests:  8
  ✅ Passed:    8
  ❌ Failed:    0
  Pass Rate:    100.0%

🎉 ALL TESTS PASSED!
```

### Troubleshooting

**If tests fail:**
- Check the **Output** panel in Godot for specific failure messages
- Each failed test shows what went wrong
- Example: `❌ FAIL: Player not colliding with platforms (falling through?)`

**Common issues:**
- **"Failed to load level"** → Check `levels/json/world_01_level_01.json` exists
- **"Player not on floor"** → Collision layers might be misconfigured
- **"Gravity not working"** → PhysicsManager might not be initialized

### Modifying Tests

Edit `scenes/testing/E2ETestRunner.gd` to:
- Change which level is tested (line 6: `TEST_LEVEL_PATH`)
- Add new test cases (create new `test_*` functions)
- Adjust test timeouts (line 7: `TEST_TIMEOUT`)

### CI/CD Integration

To run tests from command line (for GitHub Actions):

```bash
godot --headless --script scenes/testing/E2ETestRunner.gd
```

This will output test results to stdout and exit with:
- **Exit code 0** if all tests pass
- **Exit code 1** if any tests fail
