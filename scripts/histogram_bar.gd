extends Control

var top_margin = 0.1

@export var height = 1.0:
	set(value):
		height = value
		$ColorRect.anchor_top = (1 - height) * ($ColorRect.anchor_bottom - top_margin) + top_margin

@export var score = 100:
	set(value):
		score = value
		$Label.text = str(score)
		
func set_color(color):
	$ColorRect.color = color

func hide_label():
	$Label.hide()
