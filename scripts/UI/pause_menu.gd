extends Control

func _on_main_menu_btn_pressed() -> void:
	Globals.game_controller.change_game_state(Globals.GameStates.main_menu, Globals.GameStates.in_world)

func _on_continue_button_pressed() -> void:
	Globals.game_controller.change_game_state(Globals.GameStates.in_world, Globals.GameStates.pause_menu)
