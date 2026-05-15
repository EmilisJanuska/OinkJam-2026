extends Node2D

@export var spawn_type: Globals.SpawnPointType
@export var layers: Node2D

var player: CharacterBody2D

func _ready() -> void:
	if spawn_type == Globals.SpawnPointType.player:
		var instance = Globals.game_controller.player_prefab.instantiate()
		instance.position = position
		Globals.game_controller.player_instance = instance
		layers.add_child(instance)
		player = instance
	elif spawn_type == Globals.SpawnPointType.enemy:
		print("enemy spawn")
	elif spawn_type == Globals.SpawnPointType.boss:
		print("boss spawn")
