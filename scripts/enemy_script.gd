extends CharacterBody2D

@export var stats: EnemyStats
@onready var combat_box: Area2D = $combatBox

@onready var player: CharacterBody2D = $"../Player"

var speed = 200
var startPoint: Vector2
var direction = 1
var is_chasing:= false
var chase_timer := 0.0

func _ready() -> void:
	if stats: stats.duplicate() # necessary for unique stats for this enemy instance

func _physics_process(_delta: float) -> void:
	if is_chasing:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		look_at(player.position)
		move_and_slide()
		
	if chase_timer > 0: 
		chase_timer -= _delta #delta is real time
		
		if chase_timer <= 0: # stop chase after timer runs out
			is_chasing = false

func _on_combat_box_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if body.is_in_group("player"):
		set_physics_process(false)

		# enter combat
		Globals.cur_enemy_stats = stats
		Globals.game_controller.change_game_state(Globals.GameStates.in_combat, Globals.GameStates.in_world, true)

func _on_vision_cone_area_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		is_chasing = true
		chase_timer = 0.0


func _on_vision_cone_area_body_exited(body: Node2D) -> void:
		chase_timer = 1.0 # on exit chase player for a bit more
		# need to add return logic to original 'patrol route'
