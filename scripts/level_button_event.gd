extends Control


var loaded = false

@export var text: String = "":
	set (value):
		text = value
		%Name.text = value
		loaded = true

@export var raw: int = 0:
	set (value):
		raw = value
		update_text()

@export var cooked: int = 0:
	set (value):
		cooked = value
		update_text()
		
@export var wr: int = 0:
	set(value):
		wr = value
		update_text2()
		
@onready var text1 = %Bytes.text 
@onready var text2 = %Bytes2.text

func update_text():
	%Bytes.text = text1 % [raw, cooked]

func update_text2():
	%Bytes2.text = text2 % wr
	
var level_key


func _on_button_juice_pressed():
	if !loaded:
		return
	Events.editor = false
	Events.editor_verifying = false
	Events.puzzle_index = -1
	Events.custom_level = true
	Events.custom_level_key = level_key
	get_tree().change_scene_to_file("res://scenes/compression.tscn")
