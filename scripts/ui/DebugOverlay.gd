extends CanvasLayer

## DebugOverlay — QA & Playtesting Tools
##
## Only visible in debug builds. Provides level jumping, physics injection,
## and validation tools.

@onready var panel: Panel = $Panel
@onready var level_list: ItemList = $Panel/VBox/LevelList
@onready var physics_buttons: HBoxContainer = $Panel/VBox/PhysicsButtons
@onready var stats_label: Label = $Panel/VBox/StatsLabel
@onready var validate_button: Button = $Panel/VBox/ValidateButton

var _visible := false

func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	
	hide()
	_setup_ui()
	
	# Toggle with F1
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_home"): # F1 is usually mapped to ui_home
		_visible = not _visible
		visible = _visible

func _setup_ui() -> void:
	# Populate level list
	_populate_level_list()
	
	# Create physics state buttons
	_create_physics_buttons()
	
	# Connect signals
	level_list.item_activated.connect(_on_level_selected)
	validate_button.pressed.connect(_on_validate_pressed)

func _populate_level_list() -> void:
	level_list.clear()
	
	# Scan levels directory
	var dir = DirAccess.open("res://levels/json/")
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".json"):
			level_list.add_item(file_name.get_basename())
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _create_physics_buttons() -> void:
	var states = ["Normal", "LowGravity", "HighGravity", "ReverseGravity", 
				  "ZeroFriction", "BouncyPhysics", "SlowMotion", "DoubleJump"]
	
	for state_name in states:
		var btn = Button.new()
		btn.text = state_name
		btn.pressed.connect(func(): PhysicsManager.set_state(state_name))
		physics_buttons.add_child(btn)

func _on_level_selected(index: int) -> void:
	var level_name = level_list.get_item_text(index)
	var path = "res://levels/json/%s.json" % level_name
	
	# Load level using LevelLoader
	if FileAccess.file_exists(path):
		# This requires LevelManager to support direct JSON loading
		# For now, we'll just print - full implementation needs LevelManager update
		print("[DebugOverlay] Loading level: %s" % level_name)

func _on_validate_pressed() -> void:
	var results = LevelValidator.validate_all_levels()
	LevelValidator.print_validation_report(results)
	
	# Update stats label
	stats_label.text = "Validation: %d/%d passed" % [results.passed, results.total]

func _process(_delta: float) -> void:
	if not _visible:
		return
	
	# Update stats
	var fps = Engine.get_frames_per_second()
	var current_state = PhysicsManager.get_current_state_name() if PhysicsManager.current_state else "None"
	
	stats_label.text = "FPS: %d | Physics: %s" % [fps, current_state]
