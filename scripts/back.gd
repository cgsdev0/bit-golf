extends ColorRect


func _process(delta):
	if Input.is_action_just_pressed("exit"):
		visible = !visible


func _on_cancel_btn_pressed():
	visible = false


func _on_quit_btn_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
