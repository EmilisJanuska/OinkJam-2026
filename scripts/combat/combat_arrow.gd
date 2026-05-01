extends Sprite2D

var b_hit: bool

func _ready() -> void:
	b_hit = false
	set_dir("left")

func set_dir(dir: String) -> void:
	match dir:
		"left": rotation_degrees = 0
		"right": rotation_degrees = 180
		"up": rotation_degrees = 90
		"down": rotation_degrees = 270