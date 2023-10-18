extends CenterContainer

var word = ""

var locked = false
func _ready():
	for c in $HBoxContainer.get_children():
		c.get_node("AnimationPlayer").play("RESET")
		
func _input(event):
	if locked:
		return
	if event.is_pressed() && event is InputEventKey:
		if event.keycode == KEY_ENTER || event.keycode == KEY_KP_ENTER || event.keycode == KEY_BACKSPACE:
			submit()
			return
		
		var code = OS.get_keycode_string(event.keycode)
		if code.length() != 1:
			return
		word += code
		var a = $HBoxContainer.get_child(word.length() - 1).get_node("AnimationPlayer")
		a.stop()
		a.play("type")
		if word.length() == 5:
			submit()
			
func submit():
	if word == "EVENT":
		locked = true
		%Error.stop()
		%Error.play("success")
		await %Error.animation_finished
		get_tree().change_scene_to_file("res://scenes/character_select.tscn")
	elif word == "CHEAT":
		Events.cheat()
		%Error.play("success")
		await %Error.animation_finished
		get_tree().reload_current_scene()
	else:
		%Error.stop()
		%Error.play("error")
		word = ""
