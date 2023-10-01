extends Control



			
func _ready():
	for i in range(Events.puzzles.size()):
		var btn = preload("res://scenes/level_button.tscn").instantiate()
		btn.text = str(i + 1) + "\n\n"
		if i > Events.stars.size():
			btn.disabled = true
		elif i < Events.stars.size():
			btn.stars = Events.stars[i]
		$%Grid.add_child(btn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
