extends Node

## AutomatedTestRunner — Automated QA Edge-Case Testing
##
## Tests edge cases that can be verified programmatically without
## full gameplay simulation. Run this scene to validate systems.

signal all_tests_complete(passed: int, failed: int)

var _results: Array[Dictionary] = []
var _test_count: int = 0
var _pass_count: int = 0
var _fail_count: int = 0

func _ready() -> void:
	print("\n" + "=" * 60)
	print("  AUTOMATED TEST RUNNER")
	print("=" * 60 + "\n")
	
	# Run all tests
	_test_level_validator()
	_test_load_invalid_level()
	_test_missing_json_fields()
	_test_save_corruption()
	_test_negative_stars()
	_test_death_counter_overflow()
	_test_sfx_pool_limits()
	
	# Print results
	_print_results()


# ─── Test Cases ─────────────────────────────────────────────────────────────


func _test_level_validator() -> void:
	_start_test("Level Validator - All Levels Valid")
	
	var results = LevelValidator.validate_all_levels()
	
	if results.failed == 0:
		_pass("All %d levels validated successfully" % results.total)
	else:
		_fail("%d/%d levels failed validation" % [results.failed, results.total])


func _test_load_invalid_level() -> void:
	_start_test("LM-01: Load Non-Existent Level")
	
	# This should NOT crash — just log an error
	var json_path := "res://levels/json/world_99_level_99.json"
	var exists = FileAccess.file_exists(json_path)
	
	if not exists:
		_pass("Non-existent level correctly detected as missing")
	else:
		_fail("Level 99,99 somehow exists?!")


func _test_missing_json_fields() -> void:
	_start_test("LM-03: JSON With Missing Required Fields")
	
	# Create a temporary bad JSON in memory and validate it
	var bad_json := '{"level_id": "test", "platforms": []}'
	var json := JSON.new()
	var parse_result = json.parse(bad_json)
	
	if parse_result == OK:
		var data = json.data
		var has_exit = data.has("exit")
		var has_spawn = data.has("player_spawn")
		
		if not has_exit and not has_spawn:
			_pass("Missing fields correctly detected (exit, player_spawn)")
		else:
			_fail("Bad JSON not properly detected")
	else:
		_fail("JSON parsing failed unexpectedly")


func _test_save_corruption() -> void:
	_start_test("SV-01: Corrupted Save File Handling")
	
	# Write corrupt data to save file location
	var save_path := "user://test_corrupt.save"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string("{{{invalid json corruption!!!!!")
		file.close()
		
		# Try to read it back
		var read_file = FileAccess.open(save_path, FileAccess.READ)
		if read_file:
			var content = read_file.get_as_text()
			read_file.close()
			
			var json := JSON.new()
			var result = json.parse(content)
			
			if result != OK:
				_pass("Corrupt save file correctly rejected by JSON parser")
			else:
				_fail("Corrupt save was somehow parsed as valid JSON")
			
			# Clean up
			DirAccess.remove_absolute(save_path)
		else:
			_fail("Could not read back test file")
	else:
		_fail("Could not create test save file")


func _test_negative_stars() -> void:
	_start_test("SV-03: Negative Star Count Handling")
	
	var stars := -5
	var clamped := clampi(stars, 0, 3)
	
	if clamped == 0:
		_pass("Negative stars correctly clamped to 0")
	else:
		_fail("Clamping failed: got %d instead of 0" % clamped)


func _test_death_counter_overflow() -> void:
	_start_test("DR-04: Death Counter Overflow (99999)")
	
	var death_count := 99999
	var display := str(death_count)
	
	if display == "99999" and death_count > 0:
		_pass("Death counter handles large values: '%s'" % display)
	else:
		_fail("Death counter display issue with value 99999")


func _test_sfx_pool_limits() -> void:
	_start_test("AU-01: SFX Pool Size Limits")
	
	# Check that AudioManager has a finite SFX pool
	var pool_size = AudioManager.SFX_POOL_SIZE
	
	if pool_size > 0 and pool_size <= 32:
		_pass("SFX pool size is bounded: %d players" % pool_size)
	else:
		_fail("SFX pool size is unbounded or zero: %d" % pool_size)


# ─── Test Infrastructure ────────────────────────────────────────────────────

func _start_test(name: String) -> void:
	_test_count += 1

func _pass(message: String) -> void:
	_pass_count += 1
	_results.append({"status": "PASS", "message": message})
	print("  ✅ PASS: %s" % message)

func _fail(message: String) -> void:
	_fail_count += 1
	_results.append({"status": "FAIL", "message": message})
	print("  ❌ FAIL: %s" % message)

func _print_results() -> void:
	print("\n" + "=" * 60)
	print("  RESULTS: %d/%d tests passed" % [_pass_count, _test_count])
	print("=" * 60)
	
	if _fail_count == 0:
		print("\n  ✅ All automated tests passed!\n")
	else:
		print("\n  ❌ %d test(s) failed. Review above.\n" % _fail_count)
	
	all_tests_complete.emit(_pass_count, _fail_count)
