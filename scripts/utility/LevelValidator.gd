class_name LevelValidator
extends RefCounted

## LevelValidator — Automated Level Integrity Checking
##
## Validates all JSON levels for structural issues, missing required fields,
## and potential gameplay problems.

static func validate_all_levels() -> Dictionary:
	var results := {
		"total": 0,
		"passed": 0,
		"failed": 0,
		"errors": []
	}
	
	var dir = DirAccess.open("res://levels/json/")
	if not dir:
		results.errors.append("Failed to open levels directory")
		return results
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".json"):
			results.total += 1
			var validation = _validate_level_file("res://levels/json/" + file_name)
			
			if validation.is_valid:
				results.passed += 1
			else:
				results.failed += 1
				results.errors.append({
					"file": file_name,
					"issues": validation.issues
				})
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return results

static func _validate_level_file(path: String) -> Dictionary:
	var result := {
		"is_valid": true,
		"issues": []
	}
	
	# 1. Check file exists and is readable
	if not FileAccess.file_exists(path):
		result.is_valid = false
		result.issues.append("File does not exist")
		return result
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		result.is_valid = false
		result.issues.append("Cannot read file")
		return result
	
	var json_text = file.get_as_text()
	file.close()
	
	# 2. Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		result.is_valid = false
		result.issues.append("Invalid JSON syntax at line %d" % json.get_error_line())
		return result
	
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		result.is_valid = false
		result.issues.append("JSON root must be a dictionary")
		return result
	
	# 3. Check required fields
	var required_fields = ["level_id", "player_spawn", "exit", "platforms"]
	for field in required_fields:
		if not data.has(field):
			result.is_valid = false
			result.issues.append("Missing required field: %s" % field)
	
	if not result.is_valid:
		return result
	
	# 4. Validate player spawn
	if typeof(data.player_spawn) != TYPE_ARRAY or data.player_spawn.size() != 2:
		result.is_valid = false
		result.issues.append("player_spawn must be [x, y] array")
	
	# 5. Validate exit
	if not data.exit.has("position") or typeof(data.exit.position) != TYPE_ARRAY:
		result.is_valid = false
		result.issues.append("exit must have position [x, y]")
	
	# 6. Validate platforms (at least one)
	if typeof(data.platforms) != TYPE_ARRAY or data.platforms.size() == 0:
		result.is_valid = false
		result.issues.append("Must have at least one platform")
	
	# 7. Validate physics triggers reference valid states
	if data.has("physics_triggers"):
		for trigger in data.physics_triggers:
			if trigger.has("state"):
				var state_name = trigger.state
				if not PhysicsManager._states.has(state_name):
					result.is_valid = false
					result.issues.append("Unknown physics state: %s" % state_name)
	
	return result

static func print_validation_report(results: Dictionary) -> void:
	print("\n=== Level Validation Report ===")
	print("Total levels: %d" % results.total)
	print("Passed: %d" % results.passed)
	print("Failed: %d" % results.failed)
	
	if results.failed > 0:
		print("\nErrors found:")
		for error in results.errors:
			print("\n  File: %s" % error.file)
			for issue in error.issues:
				print("    - %s" % issue)
	else:
		print("\n✅ All levels validated successfully!")
