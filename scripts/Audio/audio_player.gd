class_name AudioPlayer
extends Node2D

var player_spawn
var player

@export var event_names: Array = [
	"Play_ENEMY_Aggro_Close_Attack",
	"Play_ENEMY_CBT_Damage",
	"Play_ENEMY_Random_Snores_No_Limitation",
	"Play_ENVIRO_Combat_Timer_End_Pattern_Switch",
	"Play_MUSIC",
	"Play_PLAYER_CBT_wrong_btn",
	"Play_PLAYER_Footsteps",
	"Play_PLAYER_Human_Breaths",
	"Play_UI_Menu_button_hover",
	"Play_UI_Menu_button_pressed"
]

# listed in the same order as event_names
enum event {
	EnemyAggroCloseAttack,  # done
	EnemyCombatDamage, 		# done
	EnemyRandomSnores, 		# currently does not play
	CombatTimerExpire, 		# done
	BackgroundMusic, 		# currently does not play
	CombatWrongButton, 		# done
	PlayerFootsteps, 		# done
	PlayerBreaths, 			# needs to be lower volume
	UIMenuButtonHover, 		# done
	UIMenuButtonPressed 	# done
}

func _process(_delta: float) -> void:
	if player != null:
		position = player.position

func update_spawn_point(spawn_point) -> void:
		if spawn_point != null:
			player_spawn = spawn_point
			player = player_spawn.player
			#print(player)

func play_sound(sound: int) -> void:
	Wwise.post_event(event_names[sound], self)
		
