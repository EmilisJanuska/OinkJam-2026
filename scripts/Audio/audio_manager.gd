extends Node

func _ready() -> void:
	Wwise.register_game_obj(self, self.name)
	Wwise.load_bank("Main")
	Wwise.add_default_listener(self)

func play_sound(_event_name: String) -> void:
	#Wwise.post_event(event_name, self)
	pass
