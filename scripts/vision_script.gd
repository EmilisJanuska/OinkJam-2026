extends Area2D

signal player_detected(body: Node2D)
@onready var FOVcollision: CollisionPolygon2D = $FOVcollision
@onready var raycasts = [$RayCast2D, $RayCast2D2, $RayCast2D3]

var player: Node2D

func _physics_process(delta: float) -> void:
	if not player: return

	if _is_detected(player):
		player_detected.emit(player)
		player = null

func _is_detected(player):
	raycasts[0].look_at(player.global_position - 16 * transform.y)
	raycasts[1].look_at(player.global_position)
	raycasts[2].look_at(player.global_position + 16 * transform.y)

	for raycast: RayCast2D in raycasts:
		if raycast.is_colliding():
			if raycast.get_collider().is_in_group("player"):
				return true
	return false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null

func set_color(color):
	FOVcollision.change_color(color)
	
