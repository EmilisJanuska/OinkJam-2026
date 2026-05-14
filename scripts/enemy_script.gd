extends CharacterBody2D

@export var stats: EnemyStats
@onready var combat_box: Area2D = $combatBox
@onready var vision_cone: Polygon2D = $VisionCone2D/VisionConeRenderer
@onready var player: CharacterBody2D = $"../Player"

@onready var enemy = $AnimatedSprite2D
var speed = 200
var startPoint: Vector2
var is_chasing:= false
var chase_timer := 0.0
var current_direction = Vector2.ZERO
var current_animation = ""


func _ready() -> void:
	if stats: stats.duplicate() # necessary for unique stats for this enemy instance

func _physics_process(_delta: float) -> void:
		if not startPoint: startPoint = global_position
	
		if is_chasing:
			var direction = (player.position - position).normalized()
			velocity = direction * speed
			move_and_slide()
			animation_play()
			
		if chase_timer > 0: 
			chase_timer -= _delta #delta is real time
			
			if chase_timer <= 0: # stop chase after timer runs out
				is_chasing = false
				vision_cone.color = Color(0, 1, 0, 0.3)


func animation_play():
	if velocity.length() == 0:
		enemy.play("back_Idle")
		return
	
	if abs(velocity.x) > abs(velocity.y):
		enemy.play("side_Walk")

		enemy.flip_h = velocity.x < 0

	else:
		enemy.flip_h = false
		if velocity.y < 0:
			enemy.play("walk_up")
		else:
			enemy.play("walk_down")
	

func _on_combat_box_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if body.is_in_group("player"):
		set_physics_process(false)

		# enter combat
		Globals.cur_enemy_stats = stats
		Globals.game_controller.change_game_state(Globals.GameStates.in_combat, Globals.GameStates.in_world, true)
		
		queue_free() # despawns enemy need to detect whether player won or not !!!!
		


func _on_vision_cone_area_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		is_chasing = true
		vision_cone.color = Color(1, 0 ,0, 0.3)
		chase_timer = 0.0
		


func _on_vision_cone_area_body_exited(body: Node2D) -> void:
		vision_cone.color = Color(1,1,0,0.3)
		chase_timer = 2.0 # on exit chase player for a bit more
		# need to add return logic to original 'patrol route'

	
