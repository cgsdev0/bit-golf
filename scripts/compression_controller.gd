extends Control

# BLUE: asdf
# GREEN: aa
# RED: f

var puzzle = null
var raw_text

const MAX_BYTES = 512

var score_string = """ Bytes:
 {input} -> {output}

 Quota: 
 [color={quota0_color}]{quota0}[/color][color={cc_str}]/[/color][color={quota1_color}]{quota1}[/color][color={cc_str}]/[/color][color={quota2_color}]{quota2}[/color]
"""

var verify_string = """ 


 Bytes:
 {input} -> {output}
"""

var editor_string = """ 


 Bytes:
 [color={limit_color}]{bytes} / {byte_limit}[/color]
"""

var cc_str = "#75715e"
var comment_color = Color.from_string(cc_str, Color.WHITE)

var stars = 0
var bytes = -1

func reset_stars():
	$%Stars/StarSlot/AnimationPlayer.play("RESET")
	$%Stars/StarSlot2/AnimationPlayer.play("RESET")
	$%Stars/StarSlot3/AnimationPlayer.play("RESET")
	
var star_volume = 8.0
func drop_stars(n: int):
	%Stars/StarSlot/Star.texture.region.position.x = 48
	%Stars/StarSlot2/Star.texture.region.position.x = 48
	%Stars/StarSlot3/Star.texture.region.position.x = 48
	$%Stars/StarSlot/Ding.volume_db = star_volume
	$%Stars/StarSlot2/Ding.volume_db = star_volume
	$%Stars/StarSlot3/Ding.volume_db = star_volume
	if n > 0:
		$%Stars/StarSlot/AnimationPlayer.play("fill")
		$%Stars/StarSlot/Ding.play()
	if n > 1:
		await get_tree().create_timer(0.25).timeout
		$%Stars/StarSlot2/AnimationPlayer.play("fill")
		$%Stars/StarSlot2/Ding.play()
	if n > 2:
		await get_tree().create_timer(0.25).timeout
		$%Stars/StarSlot3/AnimationPlayer.play("fill")
		$%Stars/StarSlot3/Ding.play()
		
func _ready():
	Events.puzzle_change.connect(_on_puzzle_change)
	Events.puzzle_retry.connect(_on_puzzle_change.bind(false))
	_on_puzzle_change()
	
func _on_puzzle_change(clear_palette = true):
	if Events.custom_level:
		%Like.show()
		puzzle = Events.custom_levels[Events.custom_level_key]
	else:
		%Like.hide()
		puzzle = Events.puzzles[Events.puzzle_index]

	if clear_palette:
		stars = 0
		bytes = -1
		%Palette.reset()
	raw_text = puzzle.puzzle
	$VBoxContainer/RawText.text = raw_text
	$VBoxContainer/Compressed.text = raw_text
	render()
		
func add_span(idx: int, n: int):
	$%Palette.add_span(idx, min(12, n))
	render()


func parse(text, span):
	var result = []
	if typeof(text) == TYPE_ARRAY:
		for item in text:
			if typeof(item) == TYPE_DICTIONARY:
				result.push_back(item)
			else:
				result.push_back(parse(item, span))
	if typeof(text) == TYPE_STRING:
		# interesting things happen here
		var idx = text.find(span.text)
		while idx != -1:
			if idx > 0:
				result.push_back(text.substr(0, idx))
			result.push_back({ "color": span.color, "text": span.text, "underlined": !span.matched, "rle": span.rle, "count": 1 })
			text = text.substr(idx + span.text.length())
			idx = text.find(span.text)
			span.matched = true
		result.push_back(text)
	return result
	
func flatten(arr, result = []):
	for item in arr:
		if typeof(item) == TYPE_ARRAY:
			flatten(item, result)
		else:
			result.push_back(item)
	return result
	
func collapse(arr):
	var i = 0
	while i < arr.size():
		if typeof(arr[i]) == TYPE_DICTIONARY && arr[i].rle && arr[i].count > 0:
			var j = i + 1
			while j < arr.size():
				if typeof(arr[j]) != TYPE_DICTIONARY || !arr[j].rle || arr[j].color != arr[i].color:
					break
				arr[j].count = 0
				arr[i].count += 1
				j += 1
			i = j - 1
		i += 1
	return arr.filter(func(d): return d is String || d.count > 0)
	
@onready var original_text = $%YourScoreLabel.text
@onready var original_text2 = $%HighScoreLabel.text


@onready var editor_elements = [%TextEdit.get_parent(), %Continue]
@onready var game_elements = [%Submit, %RawText, %Compressed, %Divider]

func get_quotas():
	var diff = raw_text.length() - bytes
	var quota0 = max(bytes + 2, bytes + floor(diff / 2))
	var quota1 = max(bytes + 1, bytes + floor(diff / 4))
	return [quota0, quota1, bytes]
	
func toggle_editor_view(on):
	for item in editor_elements:
		item.visible = on
	for item in game_elements:
		item.visible = !on
	%Edit.visible = Events.editor_verifying
		
func update_editor():
	if !Events.editor || Events.editor_verifying:
		return
	var by = %TextEdit.text.length()
	%ScoreLabel.text = editor_string.format({
			"bytes": by,
			"byte_limit": MAX_BYTES,
			"limit_color": "white" if by < MAX_BYTES else "red"
		})
	toggle_editor_view(true)
	%Continue.disabled = !(by <= MAX_BYTES && by > 0)
	
func update_score(this_is_dumb_but_its_a_game_jam_so_its_ok_smile = false):
	if Events.editor && !Events.editor_verifying:
		return
	toggle_editor_view(false)
	var input = $%RawText.get_parsed_text().replace('\u200b', '').length()
	var output = $%Compressed.get_parsed_text().length()
	var cost = $%Palette.get_palette_cost()
	if this_is_dumb_but_its_a_game_jam_so_its_ok_smile:
		%Sparkles.emitting = false
		%Sparkles.hide()
		$%YourScoreLabel.text = original_text % (output + cost)
		%WinScreen.bucket = output + cost
	var quota_color = ["red", cc_str, cc_str]
	stars = 0
	bytes = output + cost
	if output + cost <= puzzle.quota2[0]:
		quota_color = ["green", "red", cc_str]
		stars += 1
	if output + cost <= puzzle.quota2[1]:
		quota_color = ["green", "green", "red"]
		stars += 1
	if output + cost <= puzzle.quota2[2]:
		quota_color = ["green", "green", "green"]
		stars += 1
		
	if Events.editor_verifying:
		$%Submit.disabled = output + cost >= input - 2
	else:
		$%Submit.disabled = output + cost > puzzle.quota2[0]
		
	$%ScoreLabel.text = (verify_string if Events.editor_verifying else score_string).format({
		"input": input, 
		"output": output + cost, 
		"quota0": puzzle.quota2[0],
		"quota1": puzzle.quota2[1],
		"quota2": puzzle.quota2[2],
		"cc_str": cc_str,
		"quota0_color": quota_color[0], 
		"quota1_color": quota_color[1], 
		"quota2_color": quota_color[2], 
		})
	if this_is_dumb_but_its_a_game_jam_so_its_ok_smile:
		%HighScoreLabel.text = "Loading..."
		var low_score = 0
		var path = "score/user/" if Events.custom_level else "score/"
		$HTTPRequest.request(Events.base_url() + path + Events.get_puzzle_id() + "?score=" + str(output + cost) + "&verification=" + $%Palette.verification().uri_encode(), PackedStringArray(), HTTPClient.METHOD_POST)
		var stuff = await $HTTPRequest.request_completed
		var result = stuff[0]
		var response_code = stuff[1]
		var headers = stuff[2]
		var body = stuff[3]
		if result != 0 or response_code != 200:
			%HighScoreLabel.text = "Network error :("
			return
		var text = body.get_string_from_utf8()
		if text == "NaN":
			%HighScoreLabel.text = "Network error :("
			return
		$%HighScoreLabel.text = original_text2 % text
		if text == str(bytes) && stars >= 3:
			if !$Timer.is_stopped():
				await $Timer.timeout
			%Sparkles.show()
			%Sparkles.emitting = true
			%Burst.emitting = true
			%Stars/StarSlot/Star.texture.region.position.x = 96
			%Stars/StarSlot2/Star.texture.region.position.x = 96
			%Stars/StarSlot3/Star.texture.region.position.x = 96
			$%Stars/StarSlot/Ding.play()
			$%Stars/StarSlot2/Ding.play()
			$%Stars/StarSlot3/Ding.play()

		
	
func render():
	var new_text = ""
	var spans = []
	for span in $%Palette.get_children():
		if !is_instance_of(span, PaletteItem):
			continue
		if !span.text:
			continue
		if span.disabled:
			continue
		spans.push_back(span)
	var parsed = [ raw_text ]
	for span in spans:
		span.matched = false
		parsed = parse(parsed, span)
	$VBoxContainer/RawText.clear()
	$VBoxContainer/Compressed.clear()
	var flat = flatten(parsed)
	var idx = 0
	for item in flat:
		if typeof(item) == TYPE_STRING:
			$VBoxContainer/RawText.append_text(item)
			idx += item.length()
		elif typeof(item) == TYPE_DICTIONARY:
			
			$VBoxContainer/RawText.push_color(item.color)
			if item.underlined:
				$VBoxContainer/RawText.push_underline()
			$VBoxContainer/RawText.append_text(item.text.replace(' ', "•"))
			if item.underlined:
				$VBoxContainer/RawText.pop()
				# we put a lil zero width space in there to make it work good
				$VBoxContainer/RawText.append_text("\u200b")
			$VBoxContainer/RawText.pop()
			idx += item.text.length()
	for item in collapse(flat):
		if typeof(item) == TYPE_STRING:
			$VBoxContainer/Compressed.push_color(comment_color)
			$VBoxContainer/Compressed.append_text(item)
			$VBoxContainer/Compressed.pop()
		elif typeof(item) == TYPE_DICTIONARY:
			$VBoxContainer/Compressed.push_color(item.color)
			$VBoxContainer/Compressed.push_outline_color(item.color)
			$VBoxContainer/Compressed.push_outline_size(2)
			$VBoxContainer/Compressed.append_text("•")
			$VBoxContainer/Compressed.pop()
			$VBoxContainer/Compressed.pop()
			if item.rle:
				$VBoxContainer/Compressed.append_text("%02d" % item.count)
			$VBoxContainer/Compressed.pop()
	update_score()
	update_editor()


func _on_try_again_btn_pressed():
	Events.try_again()


func _on_next_puzzle_btn_pressed():
	Events.next_puzzle()


func _on_submit_pressed():
	if Events.editor_verifying:
		%PublishScreen/AnimationPlayer.play("fade_in")
	else:
		%Burst.emitting = false
		update_score(true)
		$Timer.start(2.0)
		Events.save_level(%Palette.verification(), bytes)
		Events.win_level.emit()
		await get_tree().create_timer(0.5).timeout
		drop_stars(stars)


func _on_text_edit_text_changed():
	update_editor()


func _on_continue_pressed():
	Events.editor_verifying = true
	raw_text = %TextEdit.text.replace("\t", "    ")
	render()


func _on_edit_pressed():
	Events.editor_verifying = false
	update_editor()


func _on_cancel_pressed():
	%PublishScreen/AnimationPlayer.play("fade_out")


func _on_like_pressed():
	%Like/Burst.emitting = true
	%Like.disabled = true
	%Like/Clink.play()
	%Like/HTTPRequest.request(Events.base_url() + "updoot/" + str(Events.custom_level_key), PackedStringArray(), HTTPClient.METHOD_POST)
	await get_tree().create_timer(0.2).timeout
	%Like/Updoot.play_random()
