extends Node2D

var ref_world : Node2D
var pattern_spawner: Node2D
var pattern_count: int
var b_input_paused: bool
var b_combat_paused: bool

var combat_patterns = preload("res://scenes/combat/combat_pattern_ui.tscn")

var enemy_prefab = preload("res://scenes/combat/combat_enemy_prefab.tscn")
var enemy_sprite
var enemy_instance

var reaction_text_prefab = preload("res://scenes/UI/tween_label.tscn")

var combat_score: float
var combat_score_mod: float
var scoring_multiplier: float
var b_show_multiplier: bool
var b_adding_score: bool
var score_adding_delay: float
var score_adding_time: float

var b_enemy_damaged: bool

@export var player_health_bar: HBoxContainer
@export var enemy_health_bar: HBoxContainer
@export var enemy_container: Node2D
@export var combat_score_label: Label
@export var combat_score_mod_label: Label
@export var multiplier_label: Label
@export var initiative_label: Label
@export var enemy_start_pos: Vector2
@export var enemy_end_pos: Vector2
@export var enemy_intro_time: float
@export var reaction_text_start_pos: Vector2
@export var reaction_text_end_pos: Vector2
@export var reaction_text_color: Color
@export var reaction_text_fade_to: float
@export var reaction_text_anim_time: float
@export var attack_slash_anim: AnimatedSprite2D

func _ready() -> void:
	enemy_sprite = load(Globals.combat_enemy_sprites["test"])
	enemy_instance = enemy_prefab.instantiate()
	enemy_container.add_child(enemy_instance)
	enemy_instance.hide()

	b_combat_paused = false
	b_input_paused = false
	pattern_count = 0
	combat_score = 0.0
	combat_score_mod = 0.0
	scoring_multiplier = 1.0
	b_show_multiplier = false
	b_adding_score = false
	score_adding_delay = 0.01
	score_adding_time = 0.0
	b_enemy_damaged = false

	connect_healthbars()

	# signals
	Globals.game_controller.new_game_started.connect(handle_new_game)
	Globals.game_controller.combat_input_pressed.connect(handle_combat_input)
	Globals.game_controller.combat_started.connect(on_combat_started)
	Globals.game_controller.combat_ended.connect(on_combat_ended)
	Globals.game_controller.combat_paused.connect(on_combat_paused)
	Globals.game_controller.combat_unpaused.connect(on_combat_unpaused)

func _process(delta: float) -> void:
	b_adding_score = false
	if !b_combat_paused:
		if combat_score_mod > 0:
			b_adding_score = true
		if b_adding_score:
			var amt = combat_score_mod * 0.1
			if amt <= 0.1: # x 10 = 1
				combat_score += 1.0
				combat_score_mod = 0.0
				b_adding_score = false
			elif score_adding_time >= score_adding_delay:
				combat_score += amt
				combat_score_mod -= amt
				update_score_mod()
				update_score_label()
				score_adding_time = 0.0
			else:
				score_adding_time += delta
		else: 
			hide_score_mod()
			b_adding_score = false
		
		# TEMPORARY - will eventually do this when we end combat from this script
		Globals.combat_score = combat_score + combat_score_mod
		
		if b_show_multiplier:
			update_multiplier()

func handle_new_game() -> void:
	on_combat_ended()
	enemy_instance.position = enemy_start_pos
	enemy_instance.hide()

# input (combat only)
func handle_combat_input(input: String) -> void:
	pattern_spawner.check_input(input)

'''
	COMBAT
'''

func on_combat_started() -> void:
	$CombatCamera.make_current()
	player_health_bar.update_hearts()

	if pattern_spawner != null:
		pattern_spawner.queue_free()

	create_pattern_spawner(Globals.cur_enemy_stats)
	pattern_spawner.spawned_pattern.connect(on_pattern_spawned)
	
	enemy_intro()

func on_combat_paused() -> void:
	b_combat_paused = true
	pattern_spawner.pause_spawning()

func on_combat_unpaused() -> void:
	b_combat_paused = false
	if pattern_spawner != null:
		pattern_spawner.resume_spawning()

func on_combat_ended() -> void:
	stop_pattern_scroll()
	if pattern_spawner != null:
		pattern_spawner.queue_free()

'''
	PLAYER
'''

func damage_player() -> void:
	Globals.game_controller.player_health -= Globals.cur_enemy_stats.damage
	player_health_bar.update_hearts()

'''
	ENEMY
'''

func enemy_intro() -> void:
	enemy_instance.show()
	enemy_instance.texture = enemy_sprite
	enemy_instance.position = enemy_start_pos

	enemy_health_bar.show()
	enemy_health_bar.update_hearts()

	var tween = self.create_tween()
	tween.tween_property(enemy_instance, "position", enemy_end_pos, enemy_intro_time)
	await tween.finished

	initiative_label.show()
	var fade = initiative_label.create_tween()
	fade.tween_property(initiative_label, "scale", Vector2(1.25, 1.25), 1)
	fade.tween_property(initiative_label, "modulate:a", 0.0, 1)
	await tween.finished
	initiative_label.hide()

func damage_enemy() -> void:
	pattern_spawner.pause_spawning()
	b_input_paused = true

	attack_slash_anim.show()
	attack_slash_anim.play("slash")
	await attack_slash_anim.animation_finished
	attack_slash_anim.hide()

	var shake = enemy_instance.create_tween()
	var shake_dist = Vector2(8.0, 0.0)
	var shake_step = 0.02
	shake.tween_property(enemy_instance, "position", shake_dist, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", -shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", -shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", -shake_dist, shake_step).as_relative()

	#print("damaged enemy with epic attack move")

	@warning_ignore("narrowing_conversion")
	Globals.cur_enemy_stats.health -= Globals.game_controller.weapon_damage
	if Globals.cur_enemy_stats.health <= 0.0:
		enemy_die()
	enemy_health_bar.update_hearts()

	b_input_paused = false
	pattern_spawner.resume_spawning()

func enemy_attack() -> void:
	pattern_spawner.pause_spawning()
	b_input_paused = true

	var shake = enemy_instance.create_tween()
	var shake_start: Vector2 = enemy_instance.position
	var shake_dist:Vector2 = Vector2(8.0, 0.0)
	var shake_back_step:float = 0.25
	var shake_fwd_step:float = 0.1
	shake.tween_property(enemy_instance, "position", shake_dist, shake_back_step).as_relative()
	shake.tween_property(enemy_instance, "position", -shake_dist * 3, shake_fwd_step).as_relative()
	shake.tween_property(enemy_instance, "position", shake_start, shake_fwd_step)
	await shake.finished

	damage_player()

	b_input_paused = false
	pattern_spawner.resume_spawning()

func enemy_die() -> void:
	pattern_spawner.pause_spawning()
	b_input_paused = true

	var flip = create_tween()
	var rot_angle: float = 180.0
	var rot_time: float = 0.5

	flip.tween_property(enemy_instance, "rotation_degrees", rot_angle, rot_time)
	await flip.finished

	var die = create_tween()
	var sink_dist: float = 20.0
	var sink_time: float = 1.0

	die.tween_property(enemy_instance, "position:y", enemy_instance.position.y + sink_dist, sink_time)
	await die.finished

	Globals.cur_enemy_stats.health = Globals.cur_enemy_stats.max_health
	Globals.game_controller.change_game_state(Globals.GameStates.in_world, Globals.GameStates.in_combat)

'''
	PATTERN SYSTEM
'''

# input pattern successfully - do damage to enemy
func handle_attack_success() -> void:
	if !b_enemy_damaged:
		damage_enemy()
		b_enemy_damaged = true

# failed the pattern - no damage taken, but resets multiplier
func handle_pattern_fail() -> void:
	scoring_multiplier = 1.0
	update_multiplier()

# timer ran out - take damage, unless we already damaged the enemy
func handle_time_fail() -> void:
	if !b_enemy_damaged:
		enemy_attack()

func create_pattern_spawner(enemy_stats_ref:EnemyStats):
	if pattern_spawner == null:
		pattern_spawner = combat_patterns.instantiate()
		pattern_spawner.pattern_input_success.connect(handle_attack_success)
		pattern_spawner.pattern_input_failure.connect(handle_pattern_fail)
		pattern_spawner.symbol_input_success_time2.connect(show_reaction_text)
		pattern_spawner.symbol_input_fail2.connect(show_reaction_text)
		add_child(pattern_spawner)
		pattern_spawner.hide()
		pattern_spawner.set_patterns(enemy_stats_ref)

func on_pattern_spawned() -> void:
	if !b_enemy_damaged:
		if pattern_count > 0:
			handle_time_fail()
	b_enemy_damaged = false # allows input again
	pattern_count += 1

func stop_pattern_scroll() -> void:
	get_tree().create_timer(0.5).timeout.connect(func():
		if pattern_spawner != null:
			pattern_spawner.hide()
			pattern_spawner.stop_spawning()
	)

'''
	USER INTERFACE
'''

# show / animate / destroy reaction text to input time
func show_reaction_text(input_time: float = Globals.combat_input_precision.nope + 1) -> void:
	if !b_enemy_damaged:
		var b_scored: bool = false
		var reaction_label: Label = reaction_text_prefab.instantiate()
		reaction_label.position = reaction_text_start_pos
		reaction_label.label_settings.font_size = 42

		match input_time:
			_ when input_time < Globals.combat_input_precision.superb:
				reaction_label.text = "Superb!!"
				reaction_label.label_settings.font_color = Color(0.6, 0.05, 0.8, 1.0)
				scoring_multiplier = scoring_multiplier + 2
				b_scored = true
			_ when input_time < Globals.combat_input_precision.great:
				reaction_label.text = "Great!"
				reaction_label.label_settings.font_color = Color(0.1, 0.5, 0.9, 1.0)
				scoring_multiplier = scoring_multiplier + 1
				b_scored = true
			_ when input_time < Globals.combat_input_precision.good:
				reaction_label.text = "Good!"
				reaction_label.label_settings.font_color = Color(0.2, 1.0, 0.2, 1.0)
				scoring_multiplier = scoring_multiplier + 0.5
				b_scored = true
			_ when input_time < Globals.combat_input_precision.sure:
				reaction_label.text = "Sure."
				reaction_label.label_settings.font_color = Color(0.8, 0.8, 0.0, 1.0)
				scoring_multiplier = scoring_multiplier + 0.25
				b_scored = true
			_ when input_time < Globals.combat_input_precision.nope:
				reaction_label.text = "Nope"
				reaction_label.label_settings.font_color = Color(0.8, 0.5, 0.0, 1.0)
				b_scored = false
			_:
				reaction_label.text = "Fail"
				reaction_label.label_settings.font_color = Color(1.0, 0.0, 0.0, 1.0)
				scoring_multiplier = 1.0
				b_scored = false

		if scoring_multiplier > 1.0:
			b_show_multiplier = true
		else: b_show_multiplier = false
		if scoring_multiplier >= 50:
			scoring_multiplier = 50

		@warning_ignore("integer_division")
		if b_scored:
			combat_score_mod = combat_score_mod + (Globals.game_controller.weapon_damage * scoring_multiplier)
		if combat_score_mod > 9.0:
			b_adding_score = true

		add_child(reaction_label)

		var tween = reaction_label.create_tween()
		tween.tween_property(reaction_label, "position", reaction_text_end_pos, reaction_text_anim_time)
		tween.tween_property(reaction_label, "modulate:a", reaction_text_fade_to, reaction_text_anim_time)
		await tween.finished
		reaction_label.queue_free()

# display / animate score / multiplier
func update_score_label() -> void:
	var score: int = round(combat_score)
	combat_score_label.text = "Score: " + str(score)
	if !combat_score_label.visible: combat_score_label.show()

func update_score_mod() -> void: # shows the label if hidden
	var mod: int = round(combat_score_mod)
	combat_score_mod_label.text = str(mod)
	if !combat_score_mod_label.visible: combat_score_mod_label.show()

func hide_score_mod() -> void:
	if combat_score_mod_label.visible: combat_score_mod_label.hide()

func update_multiplier() -> void:
	var color: Color = Color(1.0, 0.0, 0.0, 1.0)
	var t_scale: Vector2 = Vector2.ONE
	match scoring_multiplier:
		_ when scoring_multiplier > 1 and scoring_multiplier <= 5:
			color = Color(0.8, 0.5, 0.0, 1.0)
			t_scale = Vector2.ONE
		_ when scoring_multiplier > 5 and scoring_multiplier <= 12:
			color = Color(0.8, 0.8, 0.0, 1.0)
			t_scale = Vector2(1.1, 1.1)
		_ when scoring_multiplier > 12 and scoring_multiplier <= 25:
			color = Color(0.2, 1.0, 0.2, 1.0)
			t_scale = Vector2(1.2, 1.2)
		_ when scoring_multiplier > 25 and scoring_multiplier <= 40:
			color = Color(0.1, 0.5, 0.9, 1.0)
			t_scale = Vector2(1.3, 1.3)
		_ when scoring_multiplier > 40:
			color = Color(0.6, 0.05, 0.8, 1.0)
			t_scale = Vector2(1.5, 1.5)
	
	multiplier_label.text = str(scoring_multiplier) + "x"
	multiplier_label.label_settings.font_color = color
	multiplier_label.scale = t_scale
	if !multiplier_label.visible: multiplier_label.show()

func hide_multiplier() -> void:
	if multiplier_label.visible: multiplier_label.hide()

func connect_healthbars() -> void:
	#print(enemy_stats)
	player_health_bar.connect_player()
	enemy_health_bar.connect_enemy()
