extends Node

var b_game_paused: bool
var game_score: float
var game_score_mod: float
var b_adding_score: bool
var score_adding_delay: float
var score_adding_time: float

@export var player_health_bar: Node2D
@export var game_score_label: Label
@export var game_score_mod_label: Label

func _ready() -> void:
	b_game_paused = false
	game_score = Globals.game_score
	game_score_mod = Globals.game_score_mod

	player_health_bar.connect_player()
	player_health_bar.update_hearts()

	Globals.game_controller.game_paused.connect(on_game_paused)
	Globals.game_controller.game_unpaused.connect(on_game_unpaused)
	Globals.game_controller.combat_ended.connect(on_combat_ended)

	# debug testing only
	Globals.game_controller.add_to_score.connect(debug_on_add_score)

func _process(delta: float) -> void:
	b_adding_score = false
	if !b_game_paused:
		if game_score_mod > 0:
			b_adding_score = true
		if b_adding_score:
			var amt = game_score_mod * 0.1
			if amt <= 0.1: # x 10 = 1
				game_score += 1.0
				game_score_mod = 0.0
				b_adding_score = false
			elif score_adding_time >= score_adding_delay:
				game_score += amt
				game_score_mod -= amt
				update_score_mod()
				update_score_label()
				score_adding_time = 0.0
			else:
				score_adding_time += delta
		else: 
			hide_score_mod()
			b_adding_score = false

func on_combat_ended() -> void:
	player_health_bar.connect_player()
	player_health_bar.update_hearts()
	game_score_mod = Globals.combat_score
	Globals.combat_score = 0.0
	print(game_score_mod)

func update_score_label() -> void:
	var score: int = round(game_score)
	game_score_label.text = "Score: " + str(score)
	if !game_score_label.visible: game_score_label.show()

func update_score_mod() -> void: # shows the label if hidden
	var mod: int = round(game_score_mod)
	game_score_mod_label.text = str(mod)
	if !game_score_mod_label.visible: game_score_mod_label.show()

func hide_score_mod() -> void:
	game_score_mod_label.hide()

func on_game_paused() -> void:
	b_game_paused = true

func on_game_unpaused() -> void:
	b_game_paused = false

# debug testing only
func debug_on_add_score() -> void:
	game_score_mod += 1000
	update_score_mod()
	
