extends Camera2D

var default_zoom := Vector2(2.5, 2.5)
var min_zoom := Vector2(2,2)
var max_zoom := Vector2(3, 3)
var zoom_step := Vector2(0.1, 0.1)

func _ready():
	zoom = default_zoom

func _input(event):
	if event.is_action_pressed("mousewheel_up"):
		zoom -= zoom_step
	elif event.is_action_pressed("mousewheel_down"):
		zoom += zoom_step
	zoom = zoom.clamp(min_zoom, max_zoom)
