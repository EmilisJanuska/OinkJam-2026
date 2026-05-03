extends Control

@export var load_scene: PackedScene
@export var in_time: float
@export var fade_in_time: float
@export var pause_time: float
@export var fade_out_time: float
@export var out_time: float
@export var splash_screen: Label

func _unhandled_input(event: InputEvent) -> void:
	if(event is InputEventKey):
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_packed(load_scene)

func _ready() -> void:
	in_time = 0.5
	fade_in_time = 1.5
	pause_time = 1.5
	fade_out_time = 1.5
	out_time = 0.5
	fade()

func fade() -> void:
	splash_screen.modulate.a = 0.0
	var tween = self.create_tween()
	tween.tween_interval(in_time)
	tween.tween_property(splash_screen, "modulate:a", 1.0, fade_in_time)
	tween.tween_interval(pause_time)
	tween.tween_property(splash_screen, "modulate:a", 0.0, fade_out_time)
	tween.tween_interval(out_time)
	await tween.finished

	get_tree().change_scene_to_packed(load_scene)
	#Globals.game_controller.change_scene("res://scenes/dev_scene.tscn")
