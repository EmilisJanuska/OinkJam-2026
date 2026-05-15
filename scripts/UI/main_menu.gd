extends Control

var ref_audio_player: AudioPlayer

func _ready() -> void:
	ref_audio_player = Globals.game_controller.audio_player

func _on_button_pressed() -> void:
	ref_audio_player.play_sound(ref_audio_player.event.UIMenuButtonPressed)
	Globals.game_controller.new_game()


func _on_button_mouse_entered() -> void:
	if ref_audio_player != null:
		ref_audio_player.play_sound(ref_audio_player.event.UIMenuButtonHover)
