extends Sprite2D

var b_hit: bool
var start_pos: Vector2
var arrow_dir: String
var anim_start_time: float
var anim_run_time: float # ms
var anim_start_pos: Vector2
var anim_target_pos: Vector2
var anim_target_rot: float # deg
var anim_rot_speed: float
var anim_target_scale: Vector2
var cur_anim_time: float # ms

func _ready() -> void:
	b_hit = false
	start_pos = position
	anim_start_time = 0.0
	anim_run_time = 0.25 # sec
	anim_start_pos = Vector2(0.0, 0.0)
	anim_target_scale = Vector2(5.0, 5.0)
	anim_rot_speed = 1.0
	arrow_dir = "left"
	set_dir(arrow_dir)

func _process(delta: float) -> void:
	if b_hit:
		if cur_anim_time < anim_run_time:
			var pos = position.lerp(anim_target_pos, cur_anim_time / anim_run_time)
			position = pos
			var rot = lerp_angle(rotation, rotation + anim_target_rot, delta * anim_rot_speed)
			rotation = rot
			var scl = scale.lerp(anim_target_scale, cur_anim_time / anim_run_time)
			cur_anim_time = cur_anim_time + delta
		else:
			hide()
			return

func set_dir(dir: String) -> void:
	#print("setting direction: ", dir)
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

func play_success_animation() -> void:
	anim_start_pos = position
	anim_target_pos = Vector2(position.x, position.y - 20.0)
	anim_target_rot = 30.0 # deg
	cur_anim_time = 0.0
	b_hit = true

func reset() -> void:
	position = start_pos
	set_dir(arrow_dir)
	scale = Vector2(1.0, 1.0)
	show()