extends GridContainer

var character = preload("res://scenes/character.tscn")

func _ready():
	for key in Events.event_players:
		var c = character.instantiate()
		c.id = key
		add_child(c)
