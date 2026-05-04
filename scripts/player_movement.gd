"""
Simple 2D character movement script for a CharacterBody2D.

- Uses input actions ("move_left", "move_right", "move_up", "move_down")
  to determine movement direction.
- Multiplies the normalized input vector by a configurable speed value.
- Applies movement every physics frame using move_and_slide().

Variables:
- speed (int): Movement speed of the character in pixels per second.
"""
extends CharacterBody2D
@export var game_camera: Camera2D
@export var speed = 300
var b_paused = false

func _ready() -> void:
	reset_physics_interpolation()
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	reset_velocity()
	await get_tree().physics_frame
	await get_tree().physics_frame
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	Globals.game_controller.game_paused.connect(on_game_paused)
	Globals.game_controller.game_unpaused.connect(on_game_unpaused)
	Globals.game_controller.new_game_started.connect(on_new_game)
	Globals.game_controller.use_game_camera.connect(on_use_game_camera)

func get_input():
	if !b_paused:
		var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = input_direction * speed
	elif b_paused:
		reset_velocity()

func _physics_process(_delta):
	if !b_paused:
		reset_velocity()
		get_input()
		move_and_slide()

func on_game_paused() -> void:
	b_paused = true

func on_game_unpaused() -> void:
	b_paused = false

func on_new_game() -> void:
	reset_velocity()

func reset_velocity() -> void:
	velocity = Vector2(0.0, 0.0)

func on_use_game_camera() -> void:
	game_camera.make_current()
