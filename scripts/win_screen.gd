extends ColorRect

var bucket = 0

func _ready():
	Events.win_level.connect(on_win)
	Events.puzzle_change.connect(on_change)
	Events.puzzle_retry.connect(on_change)
	$Panel/MarginContainer.hide()
	
func on_win():
	$AnimationPlayer.play("fade_in")

func on_change():
	$AnimationPlayer.play("fade_out")

@onready var histogram = preload("res://scenes/histogram.tscn")

func _on_graph_btn_pressed():
	$Panel/VBoxContainer.hide()
	$Panel/MarginContainer.show()
	var h = histogram.instantiate()
	h.bucket = bucket
	%HistogramContainer.add_child(h)
	%HistogramContainer.move_child(h, 0)


func _on_button_pressed():
	$Panel/VBoxContainer.show()
	$Panel/MarginContainer.hide()
	%HistogramContainer.get_child(0).queue_free()
