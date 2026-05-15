class_name GameController
extends Node

var world: Node2D
var ui: CanvasLayer
var current_scene: String
var current_ui_scene: String
var loaded_scenes: Dictionary
var loaded_ui_scenes: Dictionary
var game_state: Globals.GameStates
var last_game_state: Globals.GameStates
var b_game_started: bool
var b_game_paused: bool
var b_combat_paused: bool

var player_prefab: PackedScene = preload("res://scenes/player.tscn")
var enemy_prefab: PackedScene = preload("res://scenes/Enemy1.tscn")

var current_spawn_point
var player_instance

@export var audio_player: AudioPlayer
@export var weapon_damage: float
@export var player_health: float
@export var player_max_health: float
@export var quarter_heart_value: float

var reset_weapon_damage: float
var reset_player_health: float
var reset_player_max_health: float
var reset_quarter_heart_value: float

signal game_paused
signal game_unpaused
signal combat_paused
signal combat_unpaused
signal combat_input_pressed
signal combat_started
signal combat_ended
signal new_game_started
signal use_game_camera

func _unhandled_input(event) -> void:
	if(event is InputEventKey):
		# toggle main menu
		if event.pressed and event.keycode == KEY_ESCAPE:
			if game_state == Globals.GameStates.in_world:
				change_game_state(Globals.GameStates.pause_menu, Globals.GameStates.in_world)
			elif game_state == Globals.GameStates.in_combat:
				change_game_state(Globals.GameStates.pause_menu, Globals.GameStates.in_combat)
			elif game_state == Globals.GameStates.pause_menu:
				#print(Globals.GameStates.find_key(last_game_state))
				if b_game_started:
					change_game_state(last_game_state, Globals.GameStates.pause_menu)

		#if event.pressed and event.keycode == KEY_SPACE:
			#change_game_state(Globals.GameStates.game_win, Globals.GameStates.in_world)
			#audio_player.play_sound(audio_player.event.EnemyRandomSnores)

		# combat controls - only enabled when in combat
		if game_state == Globals.GameStates.in_combat:
			if event.pressed and event.keycode == KEY_LEFT:
				combat_input_pressed.emit("left")
			elif event.pressed and event.keycode == KEY_RIGHT:
				combat_input_pressed.emit("right")
			elif event.pressed and event.keycode == KEY_UP:
				combat_input_pressed.emit("up")
			elif event.pressed and event.keycode == KEY_DOWN:
				combat_input_pressed.emit("down")

# init the game
func _ready() -> void:
	Globals.game_controller = self
	world = $World
	ui = $UI
	audio_player = $AudioPlayer
	game_state = Globals.GameStates.main_menu
	last_game_state = Globals.GameStates.in_world
	b_game_started = false
	b_game_paused = false
	b_combat_paused = false

	reset_weapon_damage = weapon_damage
	reset_player_health  = player_health
	reset_player_max_health = player_max_health
	reset_quarter_heart_value = quarter_heart_value

	change_scene(Globals.LevelScenes.menu_background)
	change_ui_scene(Globals.HUDScenes.main_menu)

'''
	GAME LOOP
'''
func _process(_delta: float) -> void:
	pass


'''
	GAME STATE / SCENE MANAGEMENT
'''

# game state switching logic
func change_game_state(to_state: Globals.GameStates, from_state: Globals.GameStates, start_combat: bool = false) -> void:
	match to_state:
		Globals.GameStates.main_menu:
			pause_game()
			game_state = Globals.GameStates.main_menu
			last_game_state = from_state
			change_ui_scene(Globals.HUDScenes.main_menu)
			change_scene(Globals.LevelScenes.menu_background)

		Globals.GameStates.pause_menu:
			if from_state == Globals.GameStates.in_world:
				pause_game()
				game_state = Globals.GameStates.pause_menu
				last_game_state = from_state
				change_ui_scene(Globals.HUDScenes.pause_menu, false, true)
			elif from_state == Globals.GameStates.in_combat:
				pause_combat()
				game_state = Globals.GameStates.pause_menu
				last_game_state = from_state
				change_ui_scene(Globals.HUDScenes.pause_menu, false, true)

		Globals.GameStates.in_world:
			if from_state == Globals.GameStates.main_menu:
				if !b_game_started: b_game_started = true
				game_state = Globals.GameStates.in_world
				last_game_state = from_state
				# TODO: set to 'current_level' or something similar instead of directly naming the scene
				change_scene(Globals.LevelScenes.human_pens_01)
				change_ui_scene(Globals.HUDScenes.game_hud)
				unpause_game()
			if from_state == Globals.GameStates.pause_menu:
				if !b_game_started: b_game_started = true
				game_state = Globals.GameStates.in_world
				last_game_state = from_state
				change_ui_scene(Globals.HUDScenes.game_hud)
				unpause_game()
			if from_state == Globals.GameStates.in_combat:
				game_state = Globals.GameStates.in_world
				last_game_state = from_state
				# TODO: set to 'current_level' or something similar instead of directly naming the scene
				change_scene(Globals.LevelScenes.human_pens_01)
				change_ui_scene(Globals.HUDScenes.game_hud)
				use_game_camera.emit()
				unpause_game()
				combat_ended.emit()

		Globals.GameStates.in_combat:
			if from_state == Globals.GameStates.in_world:
				pause_game()
				game_state = Globals.GameStates.in_combat
				last_game_state = from_state
				change_scene(Globals.LevelScenes.combat_scene, false, true, start_combat)
				change_ui_scene(Globals.HUDScenes.combat_hud, false, true, start_combat)

		Globals.GameStates.game_over:
			if from_state == Globals.GameStates.in_combat:
				pause_game()
				game_state = Globals.GameStates.game_over
				last_game_state = from_state
				
				for scene in loaded_scenes:
					loaded_scenes[scene].queue_free()
				
				loaded_scenes.clear()

				change_scene(Globals.LevelScenes.menu_background)
				change_ui_scene(Globals.HUDScenes.game_over_menu)

		Globals.GameStates.game_win:
			pause_game()
			game_state = Globals.GameStates.game_win
			last_game_state = from_state
			change_scene(Globals.LevelScenes.menu_background)
			change_ui_scene(Globals.HUDScenes.victory_menu, true, false, false, true)

# scene change logic
func change_scene(scene: Globals.LevelScenes, delete: bool = true, keep_running: bool = false, _begin_combat: bool = false) -> void:
	var scene_name = Globals.LevelScenes.find_key(scene)
	audio_player.stop_sounds()
	if !loaded_scenes.has(scene_name) && scene_name != current_scene:
		# remove or hide current scene
		if delete:
			if loaded_scenes.has(current_scene):
				var del = loaded_scenes[current_scene]
				loaded_scenes.erase(current_scene)
				del.queue_free() # deletes the scene
		elif keep_running:
			if loaded_scenes.has(current_scene):
				loaded_scenes[current_scene].visible = false # scene will run in background

		# load and display new scene
		var new = load(Globals.level_scene_lib[scene]).instantiate()
		loaded_scenes[scene_name] = new
		#world.call_deferred("add_child", new)
		world.add_child(new)
		current_scene = scene_name
		current_spawn_point = loaded_scenes[current_scene].get_node_or_null("PlayerSpawnPoint")

		await get_tree().process_frame
		if current_spawn_point != null:
			audio_player.update_spawn_point(current_spawn_point)
		loaded_scenes[current_scene].visible = true
	elif loaded_scenes.has(scene_name) && scene_name != current_scene:
		# remove or hide current scene
		if delete:
			if loaded_scenes.has(current_scene):
				var del = loaded_scenes[current_scene]
				loaded_scenes.erase(current_scene)
				del.queue_free() # deletes the scene
		elif keep_running:
			if loaded_scenes.has(current_scene):
				loaded_scenes[current_scene].visible = false # scene will run in background
		
		# load and display new scene
		current_scene = scene_name
		current_spawn_point = loaded_scenes[current_scene].get_node_or_null("PlayerSpawnPoint")

		await get_tree().process_frame
		if current_spawn_point != null:
			audio_player.update_spawn_point(current_spawn_point)
		loaded_scenes[scene_name].visible = true

func change_ui_scene(ui_scene: Globals.HUDScenes, delete: bool = true, keep_running: bool = false, begin_combat: bool = false, _victory: bool = false) -> void:
	var scene_name = Globals.HUDScenes.find_key(ui_scene)
	audio_player.stop_sounds()
	if !loaded_ui_scenes.has(scene_name) && scene_name != current_ui_scene:
		# remove or hide old ui scene
		if delete:
			if loaded_ui_scenes.has(current_ui_scene):
				var del = loaded_ui_scenes[current_ui_scene]
				loaded_ui_scenes.erase(current_ui_scene)
				del.queue_free() # deletes the scene
		elif keep_running:
			if loaded_ui_scenes.has(current_ui_scene):
				loaded_ui_scenes[current_ui_scene].visible = false # scene will run in background

		# load and display new ui scene
		var new = load(Globals.hud_scene_lib[ui_scene]).instantiate()
		loaded_ui_scenes[scene_name] = new
		ui.add_child(new)

		if _victory:
			#print("main: ", Globals.game_score)
			new.set_score(Globals.game_score)
		current_ui_scene = scene_name

		if begin_combat:
			combat_started.emit()

		loaded_ui_scenes[current_ui_scene].visible = true
	elif loaded_ui_scenes.has(scene_name) && scene_name != current_ui_scene:
		# remove or hide old ui scene
		if delete:
			if loaded_ui_scenes.has(current_ui_scene):
				var del = loaded_ui_scenes[current_ui_scene]
				loaded_ui_scenes.erase(current_ui_scene)
				del.queue_free() # deletes the scene
		elif keep_running:
			if loaded_ui_scenes.has(current_ui_scene):
				loaded_ui_scenes[current_ui_scene].visible = false # scene will run in background

		# load and display new ui scene
		current_ui_scene = scene_name

		if begin_combat:
			combat_started.emit()

		loaded_ui_scenes[current_ui_scene].visible = true

'''
	UTILITY FUNCTIONS
'''

func enter_combat() -> void:
	change_game_state(Globals.GameStates.in_combat, Globals.GameStates.in_world, true)

func pause_game() -> void:
	b_game_paused = true
	game_paused.emit()

func unpause_game() -> void:
	b_game_paused = false
	game_unpaused.emit()

func pause_combat() -> void:
	b_combat_paused = true
	combat_paused.emit()

func unpause_combat() -> void:
	b_combat_paused = false
	combat_unpaused.emit()

func new_game() -> void:
	b_game_started = true
	game_state = Globals.GameStates.in_world
	last_game_state = Globals.GameStates.main_menu

	player_health = reset_player_health
	player_max_health = reset_player_max_health
	weapon_damage = reset_weapon_damage
	quarter_heart_value = reset_quarter_heart_value

	var scene_key = Globals.LevelScenes.find_key(Globals.LevelScenes.human_pens_01)
	if loaded_scenes.has(scene_key):
		loaded_scenes.erase(scene_key)

	var ui_scene_key = Globals.LevelScenes.find_key(Globals.HUDScenes.game_hud)
	if loaded_scenes.has(ui_scene_key):
		loaded_scenes.erase(ui_scene_key)

	change_ui_scene(Globals.HUDScenes.game_hud)
	change_scene(Globals.LevelScenes.human_pens_01)
	new_game_started.emit()
	await get_tree().process_frame
	use_game_camera.emit()
	#AudioManager.play_sound("Play_MUSIC")
	unpause_game()
