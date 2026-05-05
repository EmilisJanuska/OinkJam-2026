extends HBoxContainer

var heart_prefab: PackedScene = preload("res://scenes/UI/health_bar_heart.tscn")
var hearts: Array

# using this to determine if this uses player data, or enemy data
var b_player: bool
var b_enemy: bool

func _ready() -> void:
	b_player = false
	b_enemy = false

func init() -> void:
	if hearts.size() > 0:
		for heart in hearts:
			remove_child(heart)
			heart.queue_free()
		hearts.clear()

	var n_hearts:int = calc_num_hearts()
	if b_player:
		for i in range(0, n_hearts):
			var heart_inst = heart_prefab.instantiate()
			add_child(heart_inst)
			heart_inst.position.x = i * 41
			hearts.append(heart_inst)
	else:
		@warning_ignore("integer_division")
		for i in range(-(n_hearts / 2), n_hearts / 2):
			var heart_inst = heart_prefab.instantiate()
			add_child(heart_inst)
			heart_inst.position.x = i * 41
			hearts.append(heart_inst)


func update_hearts() -> void:
	var check_n_hearts = calc_num_hearts()
	if check_n_hearts > hearts.size():
		add_hearts(check_n_hearts - hearts.size())

	var hp = -69
	var heart_value = 400

	if b_player: hp = Globals.game_controller.player_health
	else:  hp = Globals.cur_enemy_stats.health

	for i in range(0, hearts.size()):
		var heart = hearts[i] as AnimatedSprite2D
		var heart_hp = clamp(hp - (i * heart_value), 0, heart_value)
		var frame = 4
		if heart_hp >= heart_value:
			frame = 0
		elif heart_hp < heart_value && heart_hp >= heart_value * 0.75:
			frame = 1
		elif heart_hp < heart_value * 0.75 && heart_hp >= heart_value * 0.5:
			frame = 2
		elif heart_hp < heart_value * 0.5 && heart_hp >= heart_value * 0.25:
			frame = 3

		heart.frame = frame

func calc_num_hearts() -> int:
	if b_player:
		@warning_ignore("narrowing_conversion")
		return (Globals.game_controller.player_max_health / Globals.game_controller.quarter_heart_value) / 4
	else:
		print("max hp: ", Globals.cur_enemy_stats.max_health)
		@warning_ignore("narrowing_conversion")
		return (Globals.cur_enemy_stats.max_health / Globals.game_controller.quarter_heart_value) / 4

func add_hearts(num: int) -> void:
	for i in range(0, num):
		var heart_inst = heart_prefab.instantiate()
		hearts.append(heart_inst)
		add_child(heart_inst)

func connect_player() -> void:
	b_player = true
	b_enemy = false
	init()		

func connect_enemy() -> void:
	b_player = false
	b_enemy = true
	alignment = BoxContainer.ALIGNMENT_CENTER
	init()

func animate_take_damage() -> void:
	pass

func animate_heal() -> void:
	pass
