extends Node

var pattern_spawn_timer: Timer
var pattern_lib: Array
var current_pattern: int

var pattern_spawn_delay: float # sec
var pattern_life_time: float # sec
var pattern_scroll_speed: float

var attack_pattern_prefab = preload("res://scenes/combat/attack_pattern.tscn")
var attack_patterns: Array
var attack_pattern_timers: Array

# init
func _ready() -> void:
	# define attack pattern
	pattern_lib = [
		["left", "left", "up", "up"],
		["up", "right", "down"]
	]

	# pattern settings
	current_pattern = 0 		# selected attack pattern
	pattern_spawn_delay = 2 	# time until next pattern spawns
	pattern_life_time = 2 		# time until each spawned pattern is removed
	pattern_scroll_speed = 100

	# init spawn timer
	pattern_spawn_timer = Timer.new()
	add_child(pattern_spawn_timer)
	pattern_spawn_timer.wait_time = pattern_spawn_delay
	pattern_spawn_timer.one_shot = false
	pattern_spawn_timer.timeout.connect(spawn_pattern)

# pattern spawning
func start_spawning() -> void:
	pattern_spawn_timer.start()

func stop_spawning() -> void:
	pattern_spawn_timer.stop()

func spawn_pattern() -> void:
	choose_next_pattern()
	var attack_pattern_inst = attack_pattern_prefab.instantiate()
	attack_pattern_inst.set_pattern(pattern_lib[current_pattern], pattern_life_time, pattern_scroll_speed)
	attack_pattern_inst.attack_pattern_expired.connect(handle_expired_pattern)
	add_child(attack_pattern_inst)
	attack_pattern_inst.start()
	attack_patterns.append(attack_pattern_inst)

func handle_expired_pattern(instance) -> void:
	attack_patterns.erase(instance)
	instance.queue_free()
	#print("attack_pattern ", instance, " removed")

# currently chooses a pattern randomly from the array defined in _ready
# but this will probably change so the player will select which pattern they want to use
func choose_next_pattern() -> void:
	current_pattern = randi_range(0, pattern_lib.size() - 1)
