extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _gui_input(event):
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		accept_event()
		get_parent().new_color()
