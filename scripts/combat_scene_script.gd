extends Node2D

@onready var player_anim = $combat_player
@onready var enemy_anim = $combat_pig

func _ready() -> void:
	Globals.game_controller.combat_input_pressed.connect(handle_input)
	player_anim.play("IDLE")
	enemy_anim.play("IDLE")
		
func handle_input():
	if "left":
		player_anim.play("JAB")
	elif "right":
		player_anim.play("JAB")
	elif "up":
		player_anim.play("JAB")
	if "down":
		player_anim.play("JAB")

func _on_combat_player_animation_finished() -> void:
	if player_anim.animation == "JAB":
		player_anim.play("IDLE")
