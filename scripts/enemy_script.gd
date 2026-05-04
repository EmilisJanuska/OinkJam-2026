extends CharacterBody2D
@onready var FOVcollision: CollisionPolygon2D = $Area2D/FOVcollision


var speed = 200

var startPoint: Vector2
var direction = 1

func _physics_process(_delta: float) -> void:
	if not startPoint: startPoint = global_position

	if not global_position.x > startPoint.x + 500:
		direction = -1

	elif global_position.x < startPoint.x - 500:
		direction = 1

	velocity.x = speed * direction
	look_at(global_position + velocity)

	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_physics_process(false)
		FOVcollision.change_color(Color(Color.RED, 0.3))
	