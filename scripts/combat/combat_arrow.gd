extends Sprite2D

var b_hit: bool
var start_pos: Vector2
var arrow_dir: String
var anim_start_time: float
@export var anim_run_time: float # ms
@export var anim_target_pos: Vector2
@export var anim_target_rot: float # deg
@export var anim_target_scale: Vector2
@export var anim_target_alpha: float
var cur_anim_time: float # ms

func _ready() -> void:
	b_hit = false
	start_pos = position
	arrow_dir = "left"
	set_dir(arrow_dir)
	
func reset() -> void:
	position = start_pos
	set_dir(arrow_dir)
	scale = Vector2(1.0, 1.0)
	modulate.a = 1.0
	show()

func play_success_animation() -> void:
	var tween = self.create_tween()
	tween.tween_property(self, "position", anim_target_pos, anim_run_time)
	tween.tween_property(self, "rotation_degrees", anim_target_rot, anim_run_time)
	tween.tween_property(self, "scale", anim_target_scale, anim_run_time)
	tween.tween_property(self, "modulate:a", anim_target_alpha, anim_run_time * 0.8)
	await tween.finished
	hide()

func set_dir(dir: String) -> void:
	match dir:
		"left": 
			arrow_dir = "left"
			rotation_degrees = 0
		"right":  
			arrow_dir = "right"
			rotation_degrees = 180
		"up":  
			arrow_dir = "up"
			rotation_degrees = 90
		"down":  
			arrow_dir = "down"
			rotation_degrees = 270
