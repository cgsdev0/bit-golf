extends ColorRect


var pending = false
func _process(delta):
	%Publish.disabled = %LevelName.text.strip_edges().length() == 0 || $AnimationPlayer.is_playing()


func _on_publish_pressed():
	pending = true
	await do_request()
	pending = false
	
func do_request():
	var request_headers = PackedStringArray([
		"Content-Type: application/x-www-form-urlencoded",
	])
	var quotas = %Controller.get_quotas()
	var request_body = "puzzle={puzzle}&quota0={quota0}&quota1={quota1}&quota2={quota2}&name={name}&raw_size={raw}".format({
		"puzzle": Marshalls.utf8_to_base64(%Controller.raw_text).uri_encode(),
		"quota0": quotas[0],
		"quota1": quotas[1],
		"quota2": quotas[2],
		"raw": %Controller.raw_text.length(),
		"name": %LevelName.text.uri_encode(),
	})
	var hacks = ""
	if OS.is_debug_build():
		hacks = "event/"
	$HTTPRequest.request(Events.base_url() + hacks + "publish?verification=" + $%Palette.verification().uri_encode(), request_headers, HTTPClient.METHOD_POST, request_body)
	var stuff = await $HTTPRequest.request_completed
	var result = stuff[0]
	var response_code = stuff[1]
	var headers = stuff[2]
	var body = stuff[3]
	if result != 0 or response_code != 200:
		# %HighScoreLabel.text = "Network error :("
		return
	var level_key = body.get_string_from_utf8()
	Events.save_user_level(level_key, %Palette.verification(), %Controller.bytes)
	get_tree().change_scene_to_file("res://main.tscn")
