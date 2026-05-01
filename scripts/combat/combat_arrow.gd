extends Sprite2D

var b_hit: bool
var start_pos: Vector2

func _ready() -> void:
	b_hit = false
	start_pos = position
	set_dir("left")

func set_dir(dir: String) -> void:
	#print("setting direction: ", dir)
	match dir:
		"left": rotation_degrees = 0
		"right": rotation_degrees = 180
		"up": rotation_degrees = 90
		"down": rotation_degrees = 270