extends Control

var ref_audio_player: AudioPlayer
@export var score_label: Label

func _ready() -> void:
	ref_audio_player = Globals.game_controller.audio_player

func _on_main_menu_btn_pressed() -> void:
	if ref_audio_player != null:
		ref_audio_player.play_sound(ref_audio_player.event.UIMenuButtonPressed)
	Globals.game_controller.change_game_state(Globals.GameStates.main_menu, Globals.GameStates.game_over)

func set_score(score: int) -> void:
	#print("victory score: ", score)
	score_label.text = "Score: " + str(score)


func _on_main_menu_btn_mouse_entered() -> void:
	if ref_audio_player != null:
		ref_audio_player.play_sound(ref_audio_player.event.UIMenuButtonHover)