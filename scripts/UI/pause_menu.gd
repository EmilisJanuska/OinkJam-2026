extends Control

var ref_audio_player: AudioPlayer

func _ready() -> void:
	ref_audio_player = Globals.game_controller.audio_player

func _on_main_menu_btn_pressed() -> void:
	if ref_audio_player != null:
		ref_audio_player.play_sound(ref_audio_player.event.UIMenuButtonPressed)
	Globals.game_controller.change_game_state(Globals.GameStates.main_menu, Globals.GameStates.in_world)

func _on_continue_button_pressed() -> void:
	if ref_audio_player != null:
		ref_audio_player.play_sound(ref_audio_player.event.UIMenuButtonPressed)
	var last = Globals.GameStates.find_key(Globals.game_controller.last_game_state)
	Globals.game_controller.change_game_state(Globals.GameStates[last], Globals.GameStates.pause_menu)

func _on_main_menu_btn_mouse_entered() -> void:
	if ref_audio_player != null:
		ref_audio_player.play_sound(ref_audio_player.event.UIMenuButtonHover)

func _on_continue_btn_mouse_entered() -> void:
	if ref_audio_player != null:
		ref_audio_player.play_sound(ref_audio_player.event.UIMenuButtonHover)
