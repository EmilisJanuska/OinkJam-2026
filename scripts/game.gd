extends Node

signal combat_input_pressed
signal combat_started
signal combat_ended

func _unhandled_input(event) -> void:
	if(event is InputEventKey):
		if event.pressed and event.keycode == KEY_ESCAPE:
			pass
		elif event.pressed and event.keycode == KEY_SPACE:
			toggle_begin_combat()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("Combat_Left"):
		combat_input_pressed.emit("left")

	elif Input.is_action_pressed("Combat_Right"):
		combat_input_pressed.emit("right")

	elif Input.is_action_pressed("Combat_Up"):
		combat_input_pressed.emit("up")

	elif Input.is_action_pressed("Combat_Down"):
		combat_input_pressed.emit("down")

# this is temporary, just need a way to start / stop combat for testing
# GlobalFlags is a project autoload script with variables that can be refrenced anywhere
func toggle_begin_combat():
	GlobalFlags.b_in_combat = !GlobalFlags.b_in_combat
	if GlobalFlags.b_in_combat:
		combat_started.emit()
	else: combat_ended.emit()
	print("Combat: ", GlobalFlags.b_in_combat)
