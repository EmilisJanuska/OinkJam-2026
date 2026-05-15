extends Node

func _ready() -> void:
    #Wwise.register_game_obj(self, self.name)
    #Wwise.load_bank("Init")
    #Wwise.load_bank("Main")
    #Wwise.add_default_listener(self)

    #await get_tree().process_frame
    Wwise.post_event("Play_MUSIC", self)

func play_sound(event_name: String) -> void:
    Wwise.post_event(event_name, self)