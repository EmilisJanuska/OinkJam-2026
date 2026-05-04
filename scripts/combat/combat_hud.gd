extends Node2D

var ref_world : Node2D
var pattern_spawner: Node2D

var combat_patterns = preload("res://scenes/combat/combat_pattern_ui.tscn")

var enemy_prefab = preload("res://scenes/combat/combat_enemy_prefab.tscn")
var enemy_sprite
var enemy_instance

var reaction_text_prefab = preload("res://scenes/combat/input_time_reaction.tscn")

@export var enemy_start_pos: Vector2
@export var enemy_end_pos: Vector2
@export var enemy_intro_time: float
@export var reaction_text_start_pos: Vector2
@export var reaction_text_end_pos: Vector2
@export var reaction_text_color: Color
@export var reaction_text_fade_to: float
@export var reaction_text_anim_time: float

func _ready() -> void:
	enemy_sprite = load(Globals.combat_enemy_sprites["test"])
	enemy_instance = enemy_prefab.instantiate()
	add_child(enemy_instance)
	enemy_instance.hide()

	# signals
	Globals.game_controller.new_game_started.connect(handle_new_game)
	Globals.game_controller.combat_input_pressed.connect(handle_combat_input)
	Globals.game_controller.combat_started.connect(start_pattern_scroll)
	Globals.game_controller.combat_ended.connect(stop_pattern_scroll)

func _process(_delta: float) -> void:
	pass

func handle_new_game() -> void:
	delete_pattern_spawner()
	enemy_instance.position = enemy_start_pos
	enemy_instance.hide()


# input (combat only)
func handle_combat_input(input: String) -> void:
	pattern_spawner.check_input(input)

# arrow pattern system
func start_pattern_scroll() -> void:
	if pattern_spawner == null:
		create_pattern_spawner()
		
	pattern_spawner.reset()
	pattern_spawner.show()
	pattern_spawner.start_spawning()
	enemy_intro()

func stop_pattern_scroll() -> void:
	get_tree().create_timer(0.5).timeout.connect(func():
		if pattern_spawner != null:
			pattern_spawner.hide()
			pattern_spawner.stop_spawning()
	)

func handle_attack_success() -> void:
	damage_enemy()

func handle_attack_fail() -> void:
	pass

func create_pattern_spawner():
	if pattern_spawner == null:
		pattern_spawner = combat_patterns.instantiate()
		pattern_spawner.pattern_input_success.connect(handle_attack_success)
		pattern_spawner.pattern_input_failure.connect(handle_attack_fail)
		pattern_spawner.symbol_input_success_time2.connect(show_reaction_text)
		add_child(pattern_spawner)
		pattern_spawner.hide()

func delete_pattern_spawner() -> void:
	stop_pattern_scroll()
	if pattern_spawner != null:
		pattern_spawner.queue_free()

# enemy - animations
func enemy_intro() -> void:
	enemy_instance.show()
	enemy_instance.texture = enemy_sprite
	enemy_instance.position = enemy_start_pos

	var tween = self.create_tween()
	tween.tween_property(enemy_instance, "position", enemy_end_pos, enemy_intro_time)
	await tween.finished

# show / animate / destroy reaction text to input time
func show_reaction_text(input_time: float) -> void:
	var reaction_text_inst = reaction_text_prefab.instantiate()
	var reaction_label: Label = reaction_text_inst.get_node("Label") as Label
	reaction_text_inst.position = reaction_text_start_pos

	if input_time < Globals.combat_input_precision.superb:
		reaction_label.text = "Superb!!"
		reaction_label.label_settings.font_color = Color(0.6, 0.05, 0.8, 1.0)
	elif input_time < Globals.combat_input_precision.great:
		reaction_label.text = "Great!"
		reaction_label.label_settings.font_color = Color(0.1, 0.5, 0.9, 1.0)
	elif input_time < Globals.combat_input_precision.good:
		reaction_label.text = "Good!"
		reaction_label.label_settings.font_color = Color(0.2, 1.0, 0.2, 1.0)
	elif input_time < Globals.combat_input_precision.sure:
		reaction_label.text = "Sure."
		reaction_label.label_settings.font_color = Color(0.8, 0.8, 0.0, 1.0)
	elif input_time < Globals.combat_input_precision.lol:
		reaction_label.text = "lollll"
		reaction_label.label_settings.font_color = Color(0.8, 0.5, 0.0, 1.0)
	else:
		reaction_label.text = "Fail"
		reaction_label.label_settings.font_color = Color(1.0, 0.0, 0.0, 1.0)

	add_child(reaction_text_inst)

	var tween = reaction_text_inst.create_tween()
	tween.tween_property(reaction_text_inst, "position", reaction_text_end_pos, reaction_text_anim_time)
	tween.tween_property(reaction_text_inst, "modulate:a", reaction_text_fade_to, reaction_text_anim_time)
	await tween.finished
	reaction_text_inst.queue_free()

func damage_enemy() -> void:
	var shake = enemy_instance.create_tween()
	var shake_dist = Vector2(8.0, 0.0)
	var shake_step = 0.02
	shake.tween_property(enemy_instance, "position", shake_dist, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", -shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", -shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", -shake_dist, shake_step).as_relative()

	print("damaged enemy with epic attack move")
