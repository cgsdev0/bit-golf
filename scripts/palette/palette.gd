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

func select(index: int):
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
	
func get_palette_cost():
	var cost = 0
	for item in get_children():
		if is_instance_of(item, PaletteItem):
			cost += item.text.length()
	return cost
	
func add_span(idx: int, n: int):
	var selected = find_selected()
	if selected != null:
		selected.text = $%Controller.raw_text.substr(idx, n)
