extends Node2D

var combat_arrow_prefab = preload("res://scenes/combat/combat_arrow.tscn")
var arrow_base
var arrow_hit
var arrows: Array
var life_timer: Timer
var life_time: float
var arrow_size: float
var arrow_space: float
var scroll_speed: float

signal attack_pattern_expired

# load sprites into memory
func _ready() -> void:
	arrow_base = load("res://assets/UI/combat/arrow_base.png")
	arrow_hit = load("res://assets/UI/combat/arrow_base.png")
	arrow_size = 32
	arrow_space = 10

func _process(delta: float) -> void:
	if life_timer.time_left > 0:
		for arrow in arrows:
			arrow.position.y = arrow.position.y + (scroll_speed * delta)

func start() -> void:
	# setup timer, add to scene, set callback
	#print("attack_pattern, ", self, " timer started")
	life_timer = Timer.new()
	add_child(life_timer)
	life_timer.wait_time = life_time
	life_timer.one_shot = true
	life_timer.timeout.connect(attack_pattern_timeout)

	var start_positions = calc_start_positions()
	print(start_positions)
	for i in range(0, arrows.size()):
		arrows[i].position = Vector2(start_positions[i], position.y + 32)
		arrows[i].texture = arrow_base
		add_child(arrows[i])
	
	life_timer.start()

# set up the arrow pattern, and when it expires
func set_pattern(new_pattern: Array, pattern_life_time: float, pattern_scroll_speed) -> void:
	for dir in new_pattern:
		var arrow_inst = combat_arrow_prefab.instantiate()
		arrows.append(arrow_inst)
		#print("added arrow: ", arrow_inst)
	
	life_time = pattern_life_time
	scroll_speed = pattern_scroll_speed

# executed when life timer expires
func attack_pattern_timeout() -> void:
	#print("attack_pattern, ", self, " timed out")
	life_timer.stop()
	attack_pattern_expired.emit(self)

func calc_start_positions() -> Array:
	var result: Array
	var space = arrow_space

	# it doesn't like integer division lol, too bad for godot
	@warning_ignore("integer_division")
	var imin = -(arrows.size() / 2)
	@warning_ignore("integer_division")
	var imax = arrows.size() / 2

	if arrows.size() % 2 != 0:
		imax = imax + 1
		for i in range(imin, imax):
			if i == imin:
				result.append((i * arrow_size) - (arrow_size / 2))
			else:
				result.append((i * arrow_size) + (space * (i + 1)) - (arrow_size / 2))
	else:
		for i in range(imin, imax):
			if i == imin:
				result.append((i * arrow_size) - space)
			else:
				result.append((i * arrow_size) + (space * (i + 1)))
		
	return result