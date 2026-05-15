extends Control

func _on_main_menu_btn_pressed() -> void:
	Globals.game_controller.change_game_state(Globals.GameStates.main_menu, Globals.GameStates.game_over)
