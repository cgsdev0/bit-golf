extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.button_pressed_lol.connect(on_press)
	
func on_press():
	play()
