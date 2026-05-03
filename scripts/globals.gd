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