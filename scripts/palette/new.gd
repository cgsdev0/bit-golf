extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("flash")
	pass # Replace with function body.


var oneshot = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Events.editor && !Events.editor_verifying:
		hide()
	else:
		show()
		
	if Events.puzzle_index != 0 || Events.editor || Events.get_unlock_index() > 0:
		$AnimationPlayer.stop()
		%Tutor.hide()
		return
	if $%Palette.get_child_count() > 1:
		$AnimationPlayer.get_animation("flash").loop_mode = 0
		if !oneshot:
			oneshot = true
			await get_tree().create_timer(1.0).timeout
			$%Tutor/AnimationPlayer.play("teach")
	else: 
		$AnimationPlayer.get_animation("flash").loop_mode = 1
		if !$AnimationPlayer.is_playing():
			$%Tutor/AnimationPlayer.stop()
			oneshot = false
			$AnimationPlayer.play("flash")

func _gui_input(event):
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		$Pop.play_random()
		accept_event()
		get_parent().new_color()
