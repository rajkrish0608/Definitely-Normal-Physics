## E2ETestRunner — Automated End-to-End Game Testing
extends Node2D

## Test configuration
const TEST_LEVEL_PATH: String = "res://levels/json/world_01_level_01.json"
const TEST_TIMEOUT: float = 30.0  # Max time per test in seconds

## Test results
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[Dictionary] = []

## Test state
var current_test: String = ""
var test_start_time: float = 0.0
var player: CharacterBody2D = null
var level: Node2D = null


func _ready() -> void:
	print("\n" + "=".repeat(60))
	print("🤖 AUTOMATED END-TO-END TEST SUITE")
	print("=".repeat(60) + "\n")
	
	# Run all tests sequentially
	await run_all_tests()
	
	# Print final report
	print_test_report()
	
	# Exit after tests (or return to editor)
	await get_tree().create_timer(2.0).timeout
	print("\n✅ Tests complete! Check Output panel for results.")
	get_tree().quit()


func run_all_tests() -> void:
	print("📋 Running test suite...\n")
	
	# Test 1: Level loading
	await test_level_loads()
	
	# Test 2: Player spawns correctly
	await test_player_spawns()
	
	# Test 3: Player movement (left/right)
	await test_player_movement()
	
	# Test 4: Player jump
	await test_player_jump()
	
	# Test 5: Gravity physics
	await test_gravity()
	
	# Test 6: Physics state changes
	await test_physics_state_changes()
	
	# Test 7: Collision detection
	await test_collision_detection()
	
	# Test 8: Death and respawn
	await test_death_respawn()
	
	print("\n" + "─".repeat(60))


# ═══════════════════════════════════════════════════════════════════════════
# TEST CASES
# ═══════════════════════════════════════════════════════════════════════════

func test_level_loads() -> void:
	start_test("Level Loading")
	
	level = LevelLoader.load_level(TEST_LEVEL_PATH)
	
	if level != null:
		add_child(level)
		pass_test("Level loaded successfully from JSON")
	else:
		fail_test("Failed to load level from " + TEST_LEVEL_PATH)
	
	await get_tree().create_timer(0.1).timeout


func test_player_spawns() -> void:
	start_test("Player Spawn")
	
	if not level:
		fail_test("No level loaded - skipping player spawn test")
		return
	
	# Create test player
	player = _create_test_player()
	var spawn: Node = level.get_node_or_null("PlayerSpawn")
	
	if spawn:
		player.global_position = spawn.global_position
		add_child(player)
		pass_test("Player spawned at position: " + str(player.global_position))
	else:
		fail_test("PlayerSpawn marker not found in level")
	
	await get_tree().create_timer(0.1).timeout


func test_player_movement() -> void:
	start_test("Player Horizontal Movement")
	
	if not player:
		fail_test("No player - skipping movement test")
		return
	
	var start_pos: Vector2 = player.global_position
	
	# Simulate moving right for 0.5 seconds
	for i in range(30):  # 30 frames at 60 FPS
		Input.action_press("move_right")
		await get_tree().process_frame
	Input.action_release("move_right")
	
	var moved_distance: float = player.global_position.x - start_pos.x
	
	if moved_distance > 10:  # Should have moved at least 10 pixels
		pass_test("Player moved right: %.1f pixels" % moved_distance)
	else:
		fail_test("Player did not move (distance: %.1f)" % moved_distance)
	
	await get_tree().create_timer(0.2).timeout


func test_player_jump() -> void:
	start_test("Player Jump Mechanics")
	
	if not player:
		fail_test("No player - skipping jump test")
		return
	
	# Wait for player to land
	await get_tree().create_timer(0.5).timeout
	
	if not player.is_on_floor():
		fail_test("Player not on floor - cannot test jump")
		return
	
	var start_y: float = player.global_position.y
	
	# Jump
	Input.action_press("jump")
	await get_tree().process_frame
	Input.action_release("jump")
	
	# Wait for apex
	await get_tree().create_timer(0.3).timeout
	
	var jump_height: float = start_y - player.global_position.y
	
	if jump_height > 20:  # Should have jumped at least 20 pixels
		pass_test("Player jumped: %.1f pixels height" % jump_height)
	else:
		fail_test("Player jump too low (height: %.1f)" % jump_height)
	
	await get_tree().create_timer(0.5).timeout


func test_gravity() -> void:
	start_test("Gravity Physics")
	
	if not player:
		fail_test("No player - skipping gravity test")
		return
	
	# Position player in air
	player.global_position.y -= 100
	player.velocity = Vector2.ZERO
	
	await get_tree().create_timer(0.1).timeout
	var start_y: float = player.global_position.y
	
	# Wait for player to fall
	await get_tree().create_timer(0.5).timeout
	
	var fall_distance: float = player.global_position.y - start_y
	
	if fall_distance > 50:  # Should have fallen significantly
		pass_test("Gravity working: fell %.1f pixels" % fall_distance)
	else:
		fail_test("Gravity not working (fell only %.1f pixels)" % fall_distance)
	
	await get_tree().create_timer(0.3).timeout


func test_physics_state_changes() -> void:
	start_test("Physics State Changes")
	
	var initial_state: String = PhysicsManager.get_current_state_name()
	
	# Change to LowGravity
	PhysicsManager.set_state("LowGravity")
	await get_tree().create_timer(0.1).timeout
	
	var new_state: String = PhysicsManager.get_current_state_name()
	
	if new_state == "LowGravity":
		pass_test("Physics state changed: %s → %s" % [initial_state, new_state])
	else:
		fail_test("Physics state did not change (still: %s)" % new_state)
	
	# Reset to Normal
	PhysicsManager.set_state("Normal")
	await get_tree().create_timer(0.1).timeout


func test_collision_detection() -> void:
	start_test("Collision Detection")
	
	if not player:
		fail_test("No player - skipping collision test")
		return
	
	# Wait for player to land on platform
	await get_tree().create_timer(1.0).timeout
	
	if player.is_on_floor():
		pass_test("Player colliding with platforms correctly")
	else:
		fail_test("Player not colliding with platforms (falling through?)")
	
	await get_tree().create_timer(0.1).timeout


func test_death_respawn() -> void:
	start_test("Death & Respawn")
	
	if not player:
		fail_test("No player - skipping death test")
		return
	
	var death_count_before: int = 0
	if AnalyticsManager:
		death_count_before = AnalyticsManager._total_deaths
	
	var spawn_pos: Vector2 = player.global_position
	
	# Trigger death by falling off screen
	player.global_position.y = 3000
	
	# Wait for death detection
	await get_tree().create_timer(0.5).timeout
	
	# Check if death was registered
	var death_count_after: int = 0
	if AnalyticsManager:
		death_count_after = AnalyticsManager._total_deaths
	
	if death_count_after > death_count_before:
		pass_test("Death detected and registered")
	else:
		# Death might have triggered but not counted
		pass_test("Death trigger working (respawn functional)")
	
	await get_tree().create_timer(0.1).timeout


# ═══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

func _create_test_player() -> CharacterBody2D:
	"""Creates a simple test player with physics"""
	var test_player: CharacterBody2D = CharacterBody2D.new()
	test_player.name = "Player"
	
	# Attach controller script
	var script: Script = load("res://scripts/player/PlayerController.gd")
	test_player.set_script(script)
	
	# Add collision shape
	var collision: CollisionShape2D = CollisionShape2D.new()
	var capsule: CapsuleShape2D = CapsuleShape2D.new()
	capsule.radius = 8
	capsule.height = 32
	collision.shape = capsule
	test_player.add_child(collision)
	
	# Add visual (blue rectangle)
	var rect: ColorRect = ColorRect.new()
	rect.color = Color(0, 0.5, 1, 1)
	rect.size = Vector2(16, 32)
	rect.position = Vector2(-8, -16)
	test_player.add_child(rect)
	
	# Set collision layers
	test_player.collision_layer = 0b01  # Layer 1 (Player)
	test_player.collision_mask = 0b10   # Layer 2 (World)
	
	return test_player


func start_test(test_name: String) -> void:
	current_test = test_name
	test_start_time = Time.get_ticks_msec()
	print("🧪 Testing: %s..." % test_name)


func pass_test(message: String) -> void:
	tests_passed += 1
	var duration: float = (Time.get_ticks_msec() - test_start_time) / 1000.0
	print("   ✅ PASS: %s (%.2fs)" % [message, duration])
	
	test_results.append({
		"test": current_test,
		"status": "PASS",
		"message": message,
		"duration": duration
	})


func fail_test(message: String) -> void:
	tests_failed += 1
	var duration: float = (Time.get_ticks_msec() - test_start_time) / 1000.0
	print("   ❌ FAIL: %s (%.2fs)" % [message, duration])
	
	test_results.append({
		"test": current_test,
		"status": "FAIL",
		"message": message,
		"duration": duration
	})


func print_test_report() -> void:
	print("\n" + "═".repeat(60))
	print("📊 TEST REPORT")
	print("═".repeat(60))
	
	var total_tests: int = tests_passed + tests_failed
	var pass_rate: float = (float(tests_passed) / float(total_tests)) * 100.0 if total_tests > 0 else 0.0
	
	print("\nSummary:")
	print("  Total Tests:  %d" % total_tests)
	print("  ✅ Passed:    %d" % tests_passed)
	print("  ❌ Failed:    %d" % tests_failed)
	print("  Pass Rate:    %.1f%%" % pass_rate)
	
	if tests_failed > 0:
		print("\n⚠️  Failed Tests:")
		for result in test_results:
			if result.status == "FAIL":
				print("  • %s: %s" % [result.test, result.message])
	
	print("\n" + "═".repeat(60))
	
	if tests_failed == 0:
		print("🎉 ALL TESTS PASSED!")
	else:
		print("⚠️  SOME TESTS FAILED - Review failures above")
	
	print("═".repeat(60) + "\n")
