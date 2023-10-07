class_name UserLevelItem extends MarginContainer


@export var stars: int = 0 :
	set (value):
		stars = value
		var dist = 96
		if value == 4:
			%Sparkles.show()
			%Sparkles.emitting = true
			pass
		else:
			dist = 48
			%Sparkles.hide()
			%Sparkles.emitting = false
		for i in range(3):
			%Stars.get_child(i).texture.region.position.x = dist if stars > i else 0

@export var text: String = "":
	set (value):
		text = value
		%Name.text = value

@export var subtitle: String = "":
	set (value):
		subtitle = value
		%Subtitle.text = value

@export var likes: int = 0:
	set (value):
		likes = value
		if value == 1:
			%Likes.text = str(value) + " like"
		else:
			%Likes.text = str(value) + " likes"
		
var level_key


func _on_button_pressed():
	Events.editor = false
	Events.editor_verifying = false
	Events.puzzle_index = -1
	Events.custom_level = true
	Events.custom_level_key = level_key
	get_tree().change_scene_to_file("res://scenes/compression.tscn")
