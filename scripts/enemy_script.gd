extends CharacterBody2D

@onready var vision: Area2D = $Vision

var speed = 200

var startPoint: Vector2
var direction = 1

func _physics_process(_delta: float) -> void:
	if not startPoint: startPoint = global_position

	if global_position.x > startPoint.x + 500:
		direction = -1

	elif global_position.x < startPoint.x - 500:
		direction = 1

	velocity.x = speed * direction
	look_at(global_position + velocity)

	move_and_slide()

func _on_vision_player_detected(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_physics_process(false)
		vision.set_color(Color(Color.RED, 0.3))
		
