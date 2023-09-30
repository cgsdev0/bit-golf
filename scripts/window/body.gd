extends Control

signal move_to_top

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed && (event.button_index == 1 || event.button_index == 2):
			accept_event()
			move_to_top.emit()
			var was_focused = get_owner().focused
			get_owner().focused = true
			if !was_focused:
				get_owner().queue_redraw()
