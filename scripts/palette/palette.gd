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

func new_color():
	var palette_item = preload("res://scenes/palette_item.tscn")
	var new_item = palette_item.instantiate()
	
	new_item.color = colors_mut.pop_front()
	
	var idx = get_child_count() - 1
	add_child(new_item)
	move_child(new_item, idx)
	select(idx)
	if idx == 7:
		$%NewColor.hide()
	$%Controller.render()

func select(index: int):
	if index >= get_child_count() - 1:
		return
	for item in get_children():
		if is_instance_of(item, PaletteItem):
			item.selected = false
	get_child(index).selected = true

func return_color(col):
	colors_mut.push_front(col)
	$%NewColor.show()
	
func queue_repaint():
	$%Controller.call_deferred("render") 
	
func find_selected():
	for item in get_children():
		if is_instance_of(item, PaletteItem) && item.selected:
			return item
	return null
	
func reset():
	colors_mut = colors.duplicate()
	for child in get_children():
		if is_instance_of(child, PaletteItem):
			remove_child(child)
			child.queue_free()
			
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
		selected.text = $%Controller.raw_text.substr(idx, n)
		if selected.text == "compress" && Events.puzzle_index == 0:
			$%Tutor/AnimationPlayer.play('fade_out')
