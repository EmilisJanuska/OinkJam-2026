extends AnimatedSprite2D

func _on_animation_finished() -> void:
	print("stop pig attack")
	if animation == "ATTACK":
		play("IDLE")
