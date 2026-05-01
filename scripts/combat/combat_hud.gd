extends Node2D

@export var ref_world : Node2D
var combat_patterns = preload("res://scenes/combat/combat_pattern_ui.tscn")
var pattern_spawner: Node

func _ready() -> void:
	pattern_spawner = combat_patterns.instantiate()
	add_child(pattern_spawner)

	ref_world.combat_started.connect(start_pattern_scroll)
	ref_world.combat_ended.connect(stop_pattern_scroll)

func start_pattern_scroll() -> void:
	pattern_spawner.start_spawning()

func stop_pattern_scroll() -> void:
	pattern_spawner.stop_spawning()
