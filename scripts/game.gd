class_name GameController extends Node

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

@export var weapon_damage: float
@export var player_health: float
@export var player_max_health: float
@export var quarter_heart_value: float

signal game_paused
signal game_unpaused
signal combat_paused
signal combat_unpaused
signal combat_input_pressed
signal combat_started
signal combat_ended
signal new_game_started
signal use_game_camera

# debug testing only
signal add_to_score

func _unhandled_input(event) -> void:
	if(event is InputEventKey):
		# toggle main menu
		if event.pressed and event.keycode == KEY_ESCAPE:
			if game_state == Globals.GameStates.in_world:
				change_game_state(Globals.GameStates.main_menu, Globals.GameStates.in_world)
			elif game_state == Globals.GameStates.in_combat:
				change_game_state(Globals.GameStates.main_menu, Globals.GameStates.in_combat)
			elif game_state == Globals.GameStates.main_menu:
				print(Globals.GameStates.find_key(last_game_state))
				if b_game_started:
					change_game_state(last_game_state, Globals.GameStates.main_menu)
		
		#temporary - press space to start / stop combat
		elif event.pressed and event.keycode == KEY_SPACE:
			#if game_state == Globals.GameStates.in_world:
				#change_game_state(Globals.GameStates.in_combat, Globals.GameStates.in_world)
			if game_state == Globals.GameStates.in_combat:
				change_game_state(Globals.GameStates.in_world, Globals.GameStates.in_combat)

		elif event.pressed and event.keycode == KEY_Q:
			add_to_score.emit()

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
	game_state = Globals.GameStates.main_menu
	last_game_state = Globals.GameStates.in_world
	b_game_started = false
	b_game_paused = false
	b_combat_paused = false

	change_scene(Globals.LevelScenes.menu_background)
	change_ui_scene(Globals.HUDScenes.main_menu)

'''
	GAME STATE / SCENE MANAGEMENT
'''

# game state switching logic
func change_game_state(to_state: Globals.GameStates, from_state: Globals.GameStates, start_combat: bool = false) -> void:
	match to_state:
		Globals.GameStates.main_menu:
			if from_state == Globals.GameStates.in_world:
				pause_game()
				game_state = Globals.GameStates.main_menu
				last_game_state = from_state
				change_ui_scene(Globals.HUDScenes.main_menu, false, true)
				change_scene(Globals.LevelScenes.menu_background, false, true)
			elif from_state == Globals.GameStates.in_combat:
				pause_combat()
				game_state = Globals.GameStates.main_menu
				last_game_state = from_state
				change_scene(Globals.LevelScenes.menu_background, false, true)
				change_ui_scene(Globals.HUDScenes.main_menu, false, true)

		Globals.GameStates.in_world:
			if from_state == Globals.GameStates.main_menu:
				if !b_game_started: b_game_started = true
				game_state = Globals.GameStates.in_world
				last_game_state = from_state
				change_scene(Globals.LevelScenes.dev_scene, false, true)
				change_ui_scene(Globals.HUDScenes.game_hud, false, true)
				unpause_game()
			if from_state == Globals.GameStates.in_combat:
				game_state = Globals.GameStates.in_world
				last_game_state = from_state
				change_scene(Globals.LevelScenes.dev_scene)
				change_ui_scene(Globals.HUDScenes.game_hud)
				use_game_camera.emit()
				unpause_game()
				combat_ended.emit()

		Globals.GameStates.in_combat:
			if from_state == Globals.GameStates.main_menu:
				game_state = Globals.GameStates.in_combat
				last_game_state = from_state
				change_scene(Globals.LevelScenes.combat_scene, false, true)
				change_ui_scene(Globals.HUDScenes.combat_hud, false, true)
				unpause_combat()
			if from_state == Globals.GameStates.in_world:
				pause_game()
				game_state = Globals.GameStates.in_combat
				last_game_state = from_state
				change_scene(Globals.LevelScenes.combat_scene, false, true, start_combat)
				change_ui_scene(Globals.HUDScenes.combat_hud, false, true, start_combat)

		Globals.GameStates.game_over:
			pass
		Globals.GameStates.game_win:
			pass

# scene change logic
func change_scene(scene: Globals.LevelScenes, delete: bool = true, keep_running: bool = false, _begin_combat: bool = false) -> void:
	var scene_name = Globals.LevelScenes.find_key(scene)
	if !loaded_scenes.has(scene_name) && scene_name != current_scene:
		if delete:
			if loaded_scenes.has(current_scene):
				var del = loaded_scenes[current_scene]
				loaded_scenes.erase(current_scene)
				del.queue_free() # deletes the scene
		elif keep_running:
			if loaded_scenes.has(current_scene):
				loaded_scenes[current_scene].visible = false # scene will run in background
		var new = load(Globals.level_scene_lib[scene]).instantiate()
		loaded_scenes[scene_name] = new
		#world.call_deferred("add_child", new)
		world.add_child(new)
		current_scene = scene_name
		loaded_scenes[current_scene].visible = true
	elif loaded_scenes.has(scene_name) && scene_name != current_scene:
		if delete:
			if loaded_scenes.has(current_scene):
				var del = loaded_scenes[current_scene]
				loaded_scenes.erase(current_scene)
				del.queue_free() # deletes the scene
		elif keep_running:
			if loaded_scenes.has(current_scene):
				loaded_scenes[current_scene].visible = false # scene will run in background
		current_scene = scene_name
		loaded_scenes[scene_name].visible = true

func change_ui_scene(ui_scene: Globals.HUDScenes, delete: bool = true, keep_running: bool = false, begin_combat: bool = false) -> void:
	var scene_name = Globals.HUDScenes.find_key(ui_scene)
	if !loaded_ui_scenes.has(scene_name) && scene_name != current_ui_scene:
		if delete:
			if loaded_ui_scenes.has(current_ui_scene):
				var del = loaded_ui_scenes[current_ui_scene]
				loaded_ui_scenes.erase(current_ui_scene)
				del.queue_free() # deletes the scene
		elif keep_running:
			if loaded_ui_scenes.has(current_ui_scene):
				loaded_ui_scenes[current_ui_scene].visible = false # scene will run in background
		var new = load(Globals.hud_scene_lib[ui_scene]).instantiate()
		loaded_ui_scenes[scene_name] = new
		ui.add_child(new)
		current_ui_scene = scene_name

		if begin_combat:
			combat_started.emit()

		loaded_ui_scenes[current_ui_scene].visible = true
	elif loaded_ui_scenes.has(scene_name) && scene_name != current_ui_scene:
		if delete:
			if loaded_ui_scenes.has(current_ui_scene):
				var del = loaded_ui_scenes[current_ui_scene]
				loaded_ui_scenes.erase(current_ui_scene)
				del.queue_free() # deletes the scene
		elif keep_running:
			if loaded_ui_scenes.has(current_ui_scene):
				loaded_ui_scenes[current_ui_scene].visible = false # scene will run in background
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

	var dev_scene_key = Globals.LevelScenes.find_key(Globals.LevelScenes.dev_scene)
	if loaded_scenes.has(dev_scene_key):
		loaded_scenes.erase(dev_scene_key)

	var dev_ui_scene_key = Globals.LevelScenes.find_key(Globals.HUDScenes.game_hud)
	if loaded_scenes.has(dev_ui_scene_key):
		loaded_scenes.erase(dev_ui_scene_key)

	change_ui_scene(Globals.HUDScenes.game_hud, false, true)
	change_scene(Globals.LevelScenes.dev_scene, false, true)
	new_game_started.emit()
	use_game_camera.emit()
	unpause_game()
