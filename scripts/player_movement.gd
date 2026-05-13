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
@onready var sprite = $AnimatedSprite2D
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

		if input_direction != Vector2.ZERO:
			
			if input_direction.x != 0 : # left and right
				sprite.play("side_Walk")
				if input_direction.x < 0:
					sprite.flip_h = true
				else:
					sprite.flip_h = false

			elif input_direction.y < 0: #up
				sprite.play("front_Walk")

			elif input_direction.y > 0: # down
				sprite.play("back_Walk")

		else:
			var current_animation = sprite.animation

			if current_animation == "side_Walk":
				sprite.play("side_Idle")
			elif current_animation == "back_Walk":
				sprite.play("back_Idle")
			elif current_animation == "front_Walk":
				sprite.play("front_Idle")
	
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
