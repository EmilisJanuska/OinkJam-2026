extends Control

@export var score_label: Label

func _on_main_menu_btn_pressed() -> void:
	Globals.game_controller.change_game_state(Globals.GameStates.main_menu, Globals.GameStates.game_over)

func set_score(score: int) -> void:
	#print("victory score: ", score)
	score_label.text = "Score: " + str(score)
