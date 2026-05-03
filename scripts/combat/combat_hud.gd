extends Node2D

var ref_world : Node2D
var combat_patterns = preload("res://scenes/combat/combat_pattern_ui.tscn")
var pattern_spawner: Node2D

func _ready() -> void:
	# pattern spawner setup
	create_pattern_spawner()

	Globals.game_controller.combat_input_pressed.connect(handle_combat_input)
	Globals.game_controller.combat_started.connect(start_pattern_scroll)
	Globals.game_controller.combat_ended.connect(stop_pattern_scroll)

	# signals
	pattern_spawner.pattern_input_success.connect(handle_attack_success)
	pattern_spawner.pattern_input_failure.connect(handle_attack_fail)

func handle_combat_input(input: String) -> void:
	pattern_spawner.check_input(input)

func start_pattern_scroll() -> void:
	pattern_spawner.reset()
	pattern_spawner.show()
	pattern_spawner.start_spawning()

func stop_pattern_scroll() -> void:
	get_tree().create_timer(0.5).timeout.connect(func():
		pattern_spawner.hide()
		pattern_spawner.stop_spawning()
	)

func handle_attack_success() -> void:
	print("attack was successful")
	stop_pattern_scroll()

func handle_attack_fail() -> void:
	print("attack failed")

func create_pattern_spawner():
	#print("creating pattern spawner")
	if pattern_spawner == null:
		pattern_spawner = combat_patterns.instantiate()
		#pattern_spawner.position = Vector2(900.0, 50.0)
		#print(pattern_spawner)
		add_child(pattern_spawner)
