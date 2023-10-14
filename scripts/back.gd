extends ColorRect


func _process(delta):
	if Input.is_action_just_pressed("exit"):
		visible = !visible


func _on_cancel_btn_pressed():
	visible = false


func _on_quit_btn_pressed():
	if Events.is_event():
		get_tree().change_scene_to_file("res://scenes/event.tscn")
	else:
		get_tree().change_scene_to_file("res://main.tscn")
