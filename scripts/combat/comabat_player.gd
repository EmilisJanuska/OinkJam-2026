extends AnimatedSprite2D

func _on_combat_player_animation_finished() -> void:
    print("stopping jab")
    if animation == "JAB":
        play("IDLE")
