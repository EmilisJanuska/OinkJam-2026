extends Node

@export var TimerBar: TextureProgressBar
var fill_percent: float

func _ready() -> void:
	fill_percent = 1.0

func _process(_delta: float) -> void:
	TimerBar.value = fill_percent * 100.0

func update(percent: float):
	fill_percent = percent
