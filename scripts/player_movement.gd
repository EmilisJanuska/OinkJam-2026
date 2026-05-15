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
@export var speed = 150
@onready var sprite = $AnimatedSprite2D

var ref_audio_player: AudioPlayer
@export var footstep_audio_delay = 0.21
@export var breath_audio_delay = 5.0
var step_time = 0.0
var breath_time = 0.0

var b_walking = false
var b_paused = false

signal player_spawned

func _ready() -> void:
	ref_audio_player = Globals.game_controller.audio_player
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
	player_spawned.emit(self)

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

			b_walking = true

		else:
			var current_animation = sprite.animation
			if current_animation == "side_Walk":
				sprite.play("side_Idle")
			elif current_animation == "back_Walk":
				sprite.play("back_Idle")
			elif current_animation == "front_Walk":
				sprite.play("front_Idle")
			
			b_walking = false
	
	elif b_paused:
		reset_velocity()

func _process(delta) -> void:
	if b_walking:
		if step_time < footstep_audio_delay:
			step_time += delta
		else:
			ref_audio_player.play_sound(ref_audio_player.event.PlayerFootsteps)
			step_time = 0.0

	if breath_time < breath_audio_delay:
		breath_time += delta
	else:
		#ref_audio_player.play_sound(ref_audio_player.event.PlayerBreaths)
		breath_time = 0.0

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
	