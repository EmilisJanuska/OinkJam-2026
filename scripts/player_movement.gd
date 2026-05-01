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
@export var speed = 300

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed

func _physics_process(_delta):
	get_input()
	move_and_slide()
