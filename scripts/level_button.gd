extends ButtonJuice

@export var stars: int = 0 :
	set (value):
		stars = value
		var dist = 96
		if value == 4:
			$Sparkles.show()
			$Sparkles.emitting = true
		else:
			dist = 48
			$Sparkles.hide()
			$Sparkles.emitting = false
		for i in range(3):
			$Stars.get_child(i).texture.region.position.x = dist if stars > i else 0

func _ready():
	super()
	Events.best_scores_loaded.connect(refresh_stars)
	
func refresh_stars():
	stars = Events.get_default_stars(get_index())
	
func _on_pressed():
	Events.puzzle_index = get_index()
	Events.custom_level = false
	Events.editor = false
	Events.editor_verifying = false
	get_tree().change_scene_to_file("res://scenes/compression.tscn")


func on_enter():
	if !disabled:
		player.play()

