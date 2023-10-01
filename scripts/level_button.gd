extends ButtonJuice

@export var stars: int = 0 :
	set (value):
		stars = value
		for i in range(3):
			$Stars.get_child(i).texture.region.position.x = 48 if stars > i else 0


func _on_pressed():
	Events.puzzle_index = get_index()
	get_tree().change_scene_to_file("res://scenes/compression.tscn")


func on_enter():
	if !disabled:
		player.play()

