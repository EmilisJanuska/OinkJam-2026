extends Node2D

@export var ref_world : Node2D
var combat_patterns = preload("res://scenes/combat/combat_pattern_ui.tscn")
var pattern_spawner: Node

func _ready() -> void:
	# player input
	ref_world.combat_input_pressed.connect(handle_combat_input)

	# pattern spawner setup
	create_pattern_spawner()

	# signals
	ref_world.combat_started.connect(start_pattern_scroll)
	ref_world.combat_ended.connect(stop_pattern_scroll)
	pattern_spawner.pattern_input_success.connect(handle_attack_success)
	pattern_spawner.pattern_input_failure.connect(handle_attack_fail)

func handle_combat_input(input: String) -> void:
	if ref_world.b_accept_combat_input:
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
	if pattern_spawner == null:
		pattern_spawner = combat_patterns.instantiate()
		add_child(pattern_spawner)
