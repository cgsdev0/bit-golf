class_name PaletteItem extends Control


@export var text: String = "":
	set (value):
		text = value
		$PaletteItem/Label.text = value.replace('\n', '↲').replace(' ', '\u23b5')
		
@export var color: Color = Color.WHITE:
	set (value):
		color = value
		$PaletteItem/Sprite2D.modulate = value
		
var rle: bool = false
		
var matched: bool = false

@export var selected: bool = false:
	set (value):
		selected = value
		$Selected.visible = value

var rle_sprite = preload("res://sprites/circle_rle.png")
var default_sprite = preload("res://sprites/circle.png")
	
func _input(event):
	if event.is_action_pressed("delete") && selected:
		accept_event()
		var old_idx = get_index()
		var old_parent = get_parent()
		get_parent().return_color(self.color)
		get_parent().queue_repaint()
		get_parent().remove_child(self)
		old_parent.select(old_idx)
		queue_free()
		
func _gui_input(event):
	if event is InputEventMouseButton && event.button_index == 2 && event.is_pressed():
		accept_event()
		rle = !rle
		if rle:
			$PaletteItem/Sprite2D.texture = rle_sprite
		else:
			$PaletteItem/Sprite2D.texture = default_sprite
		get_parent().queue_repaint()
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		accept_event()
		get_parent().select(get_index())
