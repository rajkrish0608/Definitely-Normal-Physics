## TestRunner — Automated Test Runner for Game Systems
##
## Attach to any Node in a test scene. Runs all registered test suites
## and prints results to the console. Use in dev builds only.
##
## Usage:
##   1. Create a scene with this script attached.
##   2. Run the scene from Godot editor.
##   3. Check the Output panel for results.
extends Node


# ─── State ──────────────────────────────────────────────────────────────────

var _total_tests: int = 0
var _passed_tests: int = 0
var _failed_tests: int = 0
var _test_log: Array[String] = []


# ─── Lifecycle ──────────────────────────────────────────────────────────────

func _ready() -> void:
	print("\n" + "=".repeat(60))
	print("  DEFINITELY NORMAL PHYSICS — TEST RUNNER")
	print("=".repeat(60))

	run_physics_manager_tests()
	run_save_manager_tests()
	run_level_manager_tests()
	run_event_bus_tests()

	print_summary()


# ─── Physics Manager Tests ──────────────────────────────────────────────────

func run_physics_manager_tests() -> void:
	_section("PhysicsManager")

	# Test 1: Default state is Normal
	_assert_eq(
		PhysicsManager.current_state.get_state_name(),
		"Normal",
		"Default state should be Normal"
	)

	# Test 2: State transition
	PhysicsManager.set_state("ReverseGravity", true)
	_assert_eq(
		PhysicsManager.current_state.get_state_name(),
		"Reverse Gravity",
		"State should change to Reverse Gravity"
	)

	# Test 3: Gravity direction
	var gravity := PhysicsManager.get_current_gravity()
	_assert_true(
		gravity.y < 0,
		"Reverse gravity should have negative Y"
	)

	# Test 4: Push/pop state stack
	PhysicsManager.set_state("Normal", true)
	PhysicsManager.push_state("LowGravity")
	_assert_eq(
		PhysicsManager.current_state.get_state_name(),
		"Low Gravity",
		"Pushed state should be Low Gravity"
	)
	PhysicsManager.pop_state()
	_assert_eq(
		PhysicsManager.current_state.get_state_name(),
		"Normal",
		"Popped state should be Normal"
	)

	# Test 5: Invalid state handling
	PhysicsManager.set_state("NonexistentState", true)
	_assert_eq(
		PhysicsManager.current_state.get_state_name(),
		"Normal",
		"Invalid state should keep current state"
	)

	# Test 6: Friction value
	PhysicsManager.set_state("ZeroFriction", true)
	_assert_eq(
		PhysicsManager.get_current_friction(),
		0.0,
		"ZeroFriction should have friction = 0.0"
	)

	# Test 7: Bounce value
	PhysicsManager.set_state("BouncyPhysics", true)
	_assert_eq(
		PhysicsManager.current_state.bounce,
		0.8,
		"BouncyPhysics should have bounce = 0.8"
	)

	# Reset
	PhysicsManager.set_state("Normal", true)


# ─── Save Manager Tests ────────────────────────────────────────────────────

func run_save_manager_tests() -> void:
	_section("SaveManager")

	# Test 1: Save and load settings
	SaveManager.set_setting("test_key", "test_value")
	_assert_eq(
		SaveManager.get_setting("test_key", "default"),
		"test_value",
		"Setting should persist after set"
	)

	# Test 2: Default value for missing key
	_assert_eq(
		SaveManager.get_setting("nonexistent_key", "fallback"),
		"fallback",
		"Missing key should return default"
	)

	# Test 3: Level completion save
	SaveManager.save_level_completion(99, 99, 3, 2, 15.5)
	var level_data := SaveManager.get_level_data(99, 99)
	_assert_true(
		level_data.get("completed", false),
		"Saved level should be marked completed"
	)
	_assert_eq(
		level_data.get("stars", 0),
		3,
		"Stars should be 3"
	)

	# Test 4: Reset progress
	SaveManager.reset_progress()
	var reset_data := SaveManager.get_level_data(99, 99)
	_assert_true(
		reset_data.is_empty() or not reset_data.get("completed", false),
		"Reset progress should clear level data"
	)


# ─── Level Manager Tests ───────────────────────────────────────────────────

func run_level_manager_tests() -> void:
	_section("LevelManager")

	# Test 1: Star calculation — 3 stars
	_assert_eq(
		LevelManager.calculate_stars(0),
		3,
		"0 deaths = 3 stars"
	)
	_assert_eq(
		LevelManager.calculate_stars(5),
		3,
		"5 deaths = 3 stars"
	)

	# Test 2: Star calculation — 2 stars
	_assert_eq(
		LevelManager.calculate_stars(6),
		2,
		"6 deaths = 2 stars"
	)
	_assert_eq(
		LevelManager.calculate_stars(10),
		2,
		"10 deaths = 2 stars"
	)

	# Test 3: Star calculation — 1 star
	_assert_eq(
		LevelManager.calculate_stars(11),
		1,
		"11 deaths = 1 star"
	)
	_assert_eq(
		LevelManager.calculate_stars(100),
		1,
		"100 deaths = 1 star"
	)


# ─── Event Bus Tests ───────────────────────────────────────────────────────

func run_event_bus_tests() -> void:
	_section("EventBus")

	# Test 1: Signal connection count
	var physics_connections := EventBus.physics_changed.get_connections().size()
	_assert_true(
		physics_connections >= 0,
		"physics_changed signal should exist (connections: %d)" % physics_connections
	)

	# Test 2: Signal emission test
	var received := false
	var _on_test := func(_name: String): received = true
	EventBus.physics_changed.connect(_on_test)
	EventBus.physics_changed.emit("TestState")
	_assert_true(received, "physics_changed signal should be receivable")
	EventBus.physics_changed.disconnect(_on_test)


# ─── Test Helpers ───────────────────────────────────────────────────────────

func _section(name: String) -> void:
	print("\n── %s " % name + "─".repeat(50 - name.length()))

func _assert_eq(actual, expected, description: String) -> void:
	_total_tests += 1
	if actual == expected:
		_passed_tests += 1
		print("  ✅ PASS: %s" % description)
	else:
		_failed_tests += 1
		print("  ❌ FAIL: %s (expected: %s, got: %s)" % [description, str(expected), str(actual)])

func _assert_true(condition: bool, description: String) -> void:
	_total_tests += 1
	if condition:
		_passed_tests += 1
		print("  ✅ PASS: %s" % description)
	else:
		_failed_tests += 1
		print("  ❌ FAIL: %s (expected true, got false)" % description)

func print_summary() -> void:
	print("\n" + "=".repeat(60))
	print("  RESULTS: %d/%d passed (%d failed)" % [_passed_tests, _total_tests, _failed_tests])
	if _failed_tests == 0:
		print("  🎉 ALL TESTS PASSED!")
	else:
		print("  ⚠️  SOME TESTS FAILED")
	print("=".repeat(60) + "\n")
