extends VBoxContainer


var colors = [
	Color.from_string("#f92672", Color.WHITE),
	Color.from_string("#ffed48", Color.WHITE),
	Color.from_string("#a6e22e", Color.WHITE), 
	Color.from_string("#66d9ef", Color.WHITE),
	Color.from_string("#ae81ff", Color.WHITE),
	Color.from_string("#fd971f", Color.WHITE),
	Color.from_string("#75715e", Color.WHITE),
	Color.from_string("#ffb3ce", Color.WHITE)
]

var colors_mut = colors.duplicate()

func new_color(text = "", rle = false):
	var palette_item = preload("res://scenes/palette_item.tscn")
	var new_item = palette_item.instantiate()
	
	new_item.color = colors_mut.pop_front()
	
	var idx = get_child_count() - 1
	add_child(new_item)
	move_child(new_item, idx)
	select(idx)
	new_item.text = text
	new_item.rle = rle
	if idx == 7:
		$%NewColor.hide()
	$%Controller.render()

func verification():
	var verif = []
	for item in get_children():
		if is_instance_of(item, PaletteItem):
			var v = "1" if item.rle else "0"
			v += item.text.replace('\n', '↲')
			verif.push_back(v)
	return Marshalls.utf8_to_base64("\n".join(PackedStringArray(verif)))
	
func select(index: int):
	if index >= get_child_count() - 1:
		return
	for item in get_children():
		if is_instance_of(item, PaletteItem):
			item.selected = false
	get_child(index).selected = true

func return_color(col):
	colors_mut.push_front(col)
	$NewColor/Delete.play_random()
	$%NewColor.show()
	
func queue_repaint():
	$%Controller.call_deferred("render") 
	
func find_selected():
	for item in get_children():
		if is_instance_of(item, PaletteItem) && item.selected:
			return item
	return null
	
func attempt_hydration():
	var verified = Events.get_palette_verification()
	if !verified:
		return
	
	var pal = Marshalls.base64_to_utf8(verified)
	for item in pal.split('\n'):
		var encoding_type = item.substr(0, 1)
		new_color(item.substr(1).replace('↲', '\n'), encoding_type == "1")
	
func reset():
	$%NewColor.show()
	colors_mut = colors.duplicate()
	for child in get_children():
		if is_instance_of(child, PaletteItem):
			remove_child(child)
			child.queue_free()
	if !Events.editor:
		attempt_hydration()
			
func play_pop():
	$%NewColor/Pop.play_random()
	
func get_palette_cost():
	var cost = 0
	for item in get_children():
		if is_instance_of(item, PaletteItem):
			cost += item.text.length()
	var count = get_child_count() - 1
	if count > 0:
		cost += 1
	if count > 2:
		cost += 1
	if count > 4:
		cost += 1
	return cost
	
func add_span(idx: int, n: int):
	var selected = find_selected()
	if selected != null:
		$NewColor/Scribble.play_random()
		selected.text = $%Controller.raw_text.substr(idx, n)
		if selected.text == "compress" && Events.puzzle_index == 0:
			$%Tutor/AnimationPlayer.play('fade_out')
