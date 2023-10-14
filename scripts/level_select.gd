extends Control


@export var peace_and_quiet = false
@export var use_localhost = false
			
func _ready():
	if OS.is_debug_build() && use_localhost:
		Events.use_localhost = true
		
	if Events.custom_level || Events.editor:
		%TabContainer.current_tab = 1
	Events.load_highscores()
	if peace_and_quiet && OS.is_debug_build():
		AudioServer.set_bus_mute(0, peace_and_quiet)
		
	for i in range(Events.puzzles.size()):
		var btn = preload("res://scenes/level_button.tscn").instantiate()
		btn.text = str(i + 1) + "\n\n"
		if i > Events.get_unlock_index():
			btn.disabled = true
		btn.stars = Events.get_default_stars(i)
		%"Default Levels".add_child(btn)

func _on_button_pressed():
	Events.editor = true
	Events.editor_verifying = false
	get_tree().change_scene_to_file("res://scenes/compression.tscn")

func _on_tab_container_tab_changed(tab):
	$TabSound.play()
