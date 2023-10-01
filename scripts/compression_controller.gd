extends Control

# BLUE: asdf
# GREEN: aa
# RED: f

var puzzle = Events.puzzles[1]
var raw_text

var score_string = """Bytes:
{input} -> {output}

Compressed: {ratio}%
[color={quota_color}]Quota:      {quota}%[/color]
"""

var comment_color = Color.from_string("#75715e", Color.WHITE)

func _ready():
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
	
func update_score():
	var input = $%RawText.get_parsed_text().replace('\u200b', '').length()
	var output = $%Compressed.get_parsed_text().length()
	var cost = $%Palette.get_palette_cost()
	var ratio = 100 - round(float(output + cost) / input * 100.0)
	var quota = puzzle.quota[0]
	$%ScoreLabel.text = score_string.format({
		"input": input, 
		"output": output + cost, 
		"ratio": ratio,
		"quota": quota,
		"quota_color": "red" if ratio < quota else "green"})
	
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
