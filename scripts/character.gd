extends Control


@export var id: String = "":
	set (value):
		id = value
		%Name.text = Events.event_players.get(id, "unknown")[0]
		%Avatar.texture = Events.event_players.get(id, "unknown")[1]
		



func _on_button_juice_pressed():
	Events.event_user_id = id
	get_tree().change_scene_to_file("res://scenes/event.tscn")
