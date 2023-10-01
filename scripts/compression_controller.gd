extends Control

# BLUE: asdf
# GREEN: aa
# RED: f

var puzzle = null
var raw_text

var score_string = """Bytes:
{input} -> {output}

Compressed: {ratio}%
Quota: [color={quota0_color}]{quota0}[/color][color={cc_str}]/[/color][color={quota1_color}]{quota1}[/color][color={cc_str}]/[/color][color={quota2_color}]{quota2}[/color][color={cc_str}]%[/color]
"""

var cc_str = "#75715e"
var comment_color = Color.from_string(cc_str, Color.WHITE)

var stars = 0

func reset_stars():
	$%Stars/StarSlot/AnimationPlayer.play("RESET")
	$%Stars/StarSlot2/AnimationPlayer.play("RESET")
	$%Stars/StarSlot3/AnimationPlayer.play("RESET")
	
func drop_stars(n: int):
	if n > 0:
		$%Stars/StarSlot/AnimationPlayer.play("fill")
	if n > 1:
		await get_tree().create_timer(0.25).timeout
		$%Stars/StarSlot2/AnimationPlayer.play("fill")
	if n > 2:
		await get_tree().create_timer(0.25).timeout
		$%Stars/StarSlot3/AnimationPlayer.play("fill")
		
func _ready():
	Events.puzzle_change.connect(_on_puzzle_change)
	_on_puzzle_change()
	
func _on_puzzle_change():
	puzzle = Events.puzzles[Events.puzzle_index]
	stars = 0
	$%Palette.reset()
	raw_text = puzzle.puzzle
	$VBoxContainer/RawText.text = raw_text
	$VBoxContainer/Compressed.text = raw_text
	render()
		
func _input(event):
	if event.is_action_pressed("ui_accept") && OS.is_debug_build():
		Events.next_puzzle()
		
		
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

func update_score(this_is_dumb_but_its_a_game_jam_so_its_ok_smile = false):
	var input = $%RawText.get_parsed_text().replace('\u200b', '').length()
	var output = $%Compressed.get_parsed_text().length()
	var cost = $%Palette.get_palette_cost()
	if this_is_dumb_but_its_a_game_jam_so_its_ok_smile:
		$%YourScoreLabel.text = original_text % (output + cost)
	var ratio = 100 - round(float(output + cost) / input * 100.0)
	var quota_color = ["red", cc_str, cc_str]
	stars = 0
	if ratio >= puzzle.quota[0]:
		quota_color = ["green", "red", cc_str]
		stars += 1
	if ratio >= puzzle.quota[1]:
		quota_color = ["green", "green", "red"]
		stars += 1
	if ratio >= puzzle.quota[2]:
		quota_color = ["green", "green", "green"]
		stars += 1
		
	$%Submit.disabled = ratio < puzzle.quota[0]
		
	$%ScoreLabel.text = score_string.format({
		"input": input, 
		"output": output + cost, 
		"ratio": ratio,
		"quota0": puzzle.quota[0],
		"quota1": puzzle.quota[1],
		"quota2": puzzle.quota[2],
		"cc_str": cc_str,
		"quota0_color": quota_color[0], 
		"quota1_color": quota_color[1], 
		"quota2_color": quota_color[2], 
		})
	
func render():
	var new_text = ""
	var spans = []
	for span in $%Palette.get_children():
		if !is_instance_of(span, PaletteItem):
			continue
		if !span.text:
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


func _on_try_again_btn_pressed():
	Events.try_again()


func _on_next_puzzle_btn_pressed():
	Events.next_puzzle()


func _on_submit_pressed():
	update_score(true)
	if Events.puzzle_index == Events.stars.size():
		Events.stars.push_back(stars)
	else:
		Events.stars[Events.puzzle_index] = max(Events.stars[Events.puzzle_index], stars)
	Events.save_game()
	Events.win_level.emit()
	await get_tree().create_timer(0.5).timeout
	drop_stars(stars)
