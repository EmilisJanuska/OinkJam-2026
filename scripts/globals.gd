extends Node
class_name GameGlobals

# global reference to main game controller
var game_controller: GameController

# store main scores and player HP here
var game_score: float
var game_score_mod: float
var combat_score: float
var cur_enemy_stats: EnemyStats

# set initial game variables
func _ready() -> void:
	game_score = 0.0
	game_score_mod = 0.0
	combat_score = 0.0

# scene loading

var hud_scene_lib: Array = [
	"res://scenes/UI/main_menu.tscn",
	"res://scenes/UI/pause_menu.tscn",
	"res://scenes/UI/game_hud.tscn",
	"res://scenes/UI/combat_hud.tscn",
	"res://scenes/UI/game_over_menu.tscn",
	"res://scenes/UI/victory_menu.tscn",
]

var level_scene_lib: Array = [
	"res://scenes/UI/menu_background.tscn",
	"res://scenes/dev_scene.tscn",
	"res://scenes/combat/combat_scene.tscn",
	"res://scenes/levels/human_pens_01.tscn"
]

enum HUDScenes {
	main_menu,
	pause_menu,
	game_hud,
	combat_hud,
	game_over_menu,
	victory_menu
}

enum LevelScenes {
	menu_background,
	dev_scene,
	combat_scene,
	human_pens_01
}



# other resources

var combat_enemy_sprites: Dictionary = {
	"test": "res://assets/UI/combat/combat_enemy_ph.png"
}

# types

enum GameStates {
	main_menu,
	pause_menu,
	in_world,
	in_combat,
	game_over,
	game_win
}

enum EnemyTypes {
	weak,
	average,
	strong,
	miniboss,
	boss
}

enum SpawnPointType {
	player,
	enemy,
	boss
}

# game settings

# this determines what multiplier is added for score
# and also is an indication of the text that is displayed
# on the hud - the number is in seconds
var combat_input_precision: Dictionary = {
	"superb": 0.1,
	"great": 0.2,
	"good": 0.3,
	"sure": 0.5,
	"nope": 1.0
}


var is_chasing = false
