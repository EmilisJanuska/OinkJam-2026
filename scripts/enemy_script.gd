extends CharacterBody2D

@export var stats: EnemyStats
@onready var combat_box: Area2D = $combatBox
@onready var vision_cone: Polygon2D = $VisionCone2D/VisionConeRenderer
@onready var player: CharacterBody2D = $"../Player"
@onready var full_vision_cone: Node2D = $VisionCone2D
@onready var enemy = $AnimatedSprite2D
var speed = 100
var startPoint: Vector2
var is_chasing:= false
var chase_timer := 0.0
var current_direction = Vector2.ZERO
var default_rotation = 0
var in_vision = false
var last_direction := Vector2.DOWN


func _ready() -> void:
	if stats: stats.duplicate() # necessary for unique stats for this enemy instance

func _physics_process(_delta: float) -> void:
		if startPoint: startPoint = global_position
	
		if is_chasing:
			var direction = (player.position - position).normalized()
			velocity = direction * speed
			full_vision_cone.look_at(player.global_position)
			full_vision_cone.rotation += deg_to_rad(-90) # DO NOT REMOVE OR WONT FACE PLAYER!!!!
	
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			update_vision_direction()
			
		animation_play()
				
		if chase_timer > 0: 
			chase_timer -= _delta #delta is real time
			
			if chase_timer <= 0: # stop chase after timer runs out
				is_chasing = false

				full_vision_cone.rotation = default_rotation
				vision_cone.color = Color(0, 1, 0, 0.3)


func update_vision_direction():
	if last_direction == Vector2.ZERO:
		return

	full_vision_cone.rotation = last_direction.angle() + deg_to_rad(-90) # adjusts offset to make it face right direction

func animation_play():
	#when moving
	if velocity.length() > 1: # keep at 1 because enemy might sometimes have small float point velocity preventing this from executing
		last_direction = velocity.normalized()
		
		if abs(velocity.x) > abs(velocity.y):
			enemy.play("side_Walk")
			enemy.flip_h = velocity.x < 0

		else:
			enemy.flip_h = false
			if velocity.y < 0:
				enemy.play("walk_up")
				
			else:
				enemy.play("walk_down")
		return

	#if idle play specfic idle animation based of last movement direction
	if abs(last_direction.x) > abs(last_direction.y):
		enemy.play("side_Idle")
		enemy.flip_h = last_direction.x < 0
	else:
		enemy.flip_h = false
		
		if last_direction.y < 0:
			enemy.play("back_Idle")
		else:
			enemy.play("back_Idle")
		
	

func _on_combat_box_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if body.is_in_group("player") and in_vision:
		set_physics_process(false)

		# enter combat
		Globals.cur_enemy_stats = stats
		Globals.game_controller.change_game_state(Globals.GameStates.in_combat, Globals.GameStates.in_world, true)
		
		queue_free() # despawns enemy need to detect whether player won or not !!!!
		


func _on_vision_cone_area_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		in_vision = true
		is_chasing = true
		vision_cone.color = Color(1, 0 ,0, 0.3)
		chase_timer = 0.0
		


func _on_vision_cone_area_body_exited(body: Node2D) -> void:
		in_vision = false
		vision_cone.color = Color(1,1,0,0.3)
		full_vision_cone.look_at(player.global_position)
		chase_timer = 2.0 # on exit chase player for a bit more
		# need to add return logic to original 'patrol route'

	
