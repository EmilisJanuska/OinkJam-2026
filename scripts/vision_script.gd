extends Area2D

signal player_seen(body: Node2D)
@onready var timer: Timer = $Timer
@onready var visonPolygon: Polygon2D = $Polygon2D


func _ready():
	visonPolygon.color = Color(1, 1, 0, 0.3)


func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):

		visonPolygon.color = Color(1, 0, 0, 0.4)
		player_seen.emit(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		timer.start()
		
func _on_timer_timeout() -> void:
	visonPolygon.color = Color(1, 1, 0, 0.3)
