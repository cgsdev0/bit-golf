extends ColorRect


func _ready():
	Events.win_level.connect(on_win)
	Events.puzzle_change.connect(on_change)
	Events.puzzle_retry.connect(on_change)
	
func on_win():
	$AnimationPlayer.play("fade_in")

func on_change():
	$AnimationPlayer.play("fade_out")
