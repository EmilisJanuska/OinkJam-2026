extends Node

signal combat_input_pressed
signal combat_started
signal combat_ended

var b_in_combat: bool
var b_accept_combat_input: bool

func _ready() -> void:
	b_accept_combat_input = false

func _unhandled_input(event) -> void:
	if(event is InputEventKey):
		if event.pressed and event.keycode == KEY_ESCAPE:
			pass
		elif event.pressed and event.keycode == KEY_SPACE:
			toggle_begin_combat()
		elif event.pressed and event.keycode == KEY_LEFT:
			combat_input_pressed.emit("left")
		elif event.pressed and event.keycode == KEY_RIGHT:
			combat_input_pressed.emit("right")
		elif event.pressed and event.keycode == KEY_UP:
			combat_input_pressed.emit("up")
		elif event.pressed and event.keycode == KEY_DOWN:
			combat_input_pressed.emit("down")

# temporary - just need a way to start combat to test the system
func toggle_begin_combat():
	b_in_combat = !b_in_combat
	if b_in_combat:
		combat_started.emit()
		b_accept_combat_input = true
	else:
		combat_ended.emit()
		b_accept_combat_input = false
	print("Combat: ", b_in_combat)
