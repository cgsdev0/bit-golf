class_name PaletteItem extends Control


@export var text: String = "":
	set (value):
		$PaletteItem/Label.text = value
		
@export var color: Color = Color.WHITE:
	set (value):
		$PaletteItem/Sprite2D.modulate = value
		
@export var selected: bool = false:
	set (value):
		$Selected.visible = value


func _gui_input(event):
	if event is InputEventMouseButton && event.button_index == 2 && event.is_pressed():
		accept_event()
		queue_free()
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		accept_event()
		get_parent().select(get_index())
