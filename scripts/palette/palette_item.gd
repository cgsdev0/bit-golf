class_name PaletteItem extends Control


@export var text: String = "":
	set (value):
		text = value
		$PaletteItem/Label.text = value.replace('\n', '↲').replace(' ', '\u23b5')
		
@export var color: Color = Color.WHITE:
	set (value):
		color = value
		$PaletteItem/Sprite2D.modulate = value
		
var matched: bool = false

@export var selected: bool = false:
	set (value):
		selected = value
		$Selected.visible = value


func _gui_input(event):
	if event is InputEventMouseButton && event.button_index == 2 && event.is_pressed():
		accept_event()
		get_parent().return_color(self.color)
		get_parent().queue_repaint()
		get_parent().remove_child(self)
		queue_free()
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		accept_event()
		get_parent().select(get_index())
