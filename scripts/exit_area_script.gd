extends Area2D

func _on_body_entered(body: Node2D) -> void:
	Globals.game_controller.change_scene(Globals.LevelScenes.human_pens_02)
