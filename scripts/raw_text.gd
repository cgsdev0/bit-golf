extends RichTextLabel

@onready var font = preload("res://fonts/PixelOperatorMono.ttf")
@onready var font_size = font.get_string_size("a")

func _gui_input(event):
	if event is InputEventMouseButton && event.button_index == 1 && !event.is_pressed():
		var start = get_selection_from()
		var end = get_selection_to()
		if start == -1 || end == -1:
			return
		$%Controller.add_span(start, abs(end - start) + 1)
		deselect()
		
#		var col = floor(event.position.x / font_size.x)
#		var row = floor(event.position.y / font_size.y)
#		var row_len = floor(get_rect().size.x / font_size.x)
#		var idx = row_len * row + col
#		if idx < get_parsed_text().length():
#			get_parent().add_span(idx, 1)
#		else:
#			print("out of bounds")
