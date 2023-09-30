extends Control

# BLUE: asdf
# GREEN: aa
# RED: f

var raw_text = Events.puzzles[1]

func _ready():
	$VBoxContainer/RawText.text = raw_text
	$VBoxContainer/Compressed.text = raw_text
	
func add_span(idx: int, n: int):
	$Palette.add_span(idx, min(8, n))
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
			result.push_back({ "color": span.color, "text": span.text, "underlined": !span.matched })
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
	
func render():
	var new_text = ""
	var spans = []
	for span in $Palette.get_children():
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
	for item in flat:
		if typeof(item) == TYPE_STRING:
			$VBoxContainer/Compressed.append_text(item)
		elif typeof(item) == TYPE_DICTIONARY:
			$VBoxContainer/Compressed.push_outline_color(item.color)
			$VBoxContainer/Compressed.push_color(item.color)
			$VBoxContainer/Compressed.push_outline_size(2)
			$VBoxContainer/Compressed.append_text("•")
			$VBoxContainer/Compressed.pop()
			$VBoxContainer/Compressed.pop()
			$VBoxContainer/Compressed.pop()
