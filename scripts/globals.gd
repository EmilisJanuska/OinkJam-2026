extends Node

var game_controller: GameController

var hud_scene_lib: Array = [
	"res://scenes/main_menu.tscn",
	"res://scenes/UI/game_hud.tscn",
	"res://scenes/UI/combat_hud.tscn"
]

var level_scene_lib: Array = [
	"res://scenes/UI/menu_background.tscn",
	"res://scenes/dev_scene.tscn",
	"res://scenes/combat/combat_scene.tscn"
]

var combat_enemy_sprites: Dictionary = {
	"test": "res://assets/UI/combat/combat_enemy_ph.png"
}

# this determines what multiplier is added for score
# and also is an indication of the text that is displayed
# on the hud
var combat_input_precision: Dictionary = {
	"superb": 0.5, # + 2x multiplier
	"great": 1, # + 1x multiplier
	"good": 1.8, # + 0.5x multiplier
	"sure": 2,
	"lol": 3.0
}

enum GameStates {
	main_menu,
	in_world,
	in_combat,
	game_over,
	game_win
}

enum HUDScenes {
	main_menu,
	game_hud,
	combat_hud
}

enum LevelScenes {
	menu_background,
	dev_scene,
	combat_scene
}