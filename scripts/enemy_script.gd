extends CharacterBody2D

@onready var vision: Area2D = $Vision
@export var stats: EnemyStats
@onready var combat_box: Area2D = $combatBox


var speed = 200
var startPoint: Vector2
var direction = 1

func _ready() -> void:
	if stats: stats.duplicate() # necessary for unique stats for this enemy instance

func _physics_process(_delta: float) -> void:
	if not startPoint: startPoint = global_position

	if global_position.x > startPoint.x + 500:
		direction = -1

	elif global_position.x < startPoint.x - 500:
		direction = 1

	velocity.x = speed * direction
	look_at(global_position + velocity)

	move_and_slide()

func _on_combat_box_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if body.is_in_group("player"):
		set_physics_process(false)

		# enter combat
		Globals.cur_enemy_stats = stats
		Globals.game_controller.change_game_state(Globals.GameStates.in_combat, Globals.GameStates.in_world, true)
