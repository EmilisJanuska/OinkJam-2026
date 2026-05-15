extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	Globals.game_controller.change_game_state(
		Globals.GameStates.game_win,
		Globals.GameStates.in_world
	)
