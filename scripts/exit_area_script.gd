extends Area2D

@export var game_win: bool
@export var next_level: GameGlobals.LevelScenes

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	if !game_win:
		Globals.game_controller.change_scene(next_level)
	else:
		Globals.game_controller.change_game_state(Globals.GameStates.game_win, Globals.GameStates.in_world)
