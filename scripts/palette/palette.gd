extends VBoxContainer


var colors = [
	Color.RED,
	Color.GREEN,
	Color.BLUE, 
	Color.ORANGE
]
# Called when the node enters the scene tree for the first time.
func new_color():
	var palette_item = preload("res://scenes/palette_item.tscn")
	var new_item = palette_item.instantiate()
	
	new_item.color = colors[(get_child_count() - 1) % colors.size()] # TODO: fix me
	
	var idx = get_child_count() - 1
	add_child(new_item)
	move_child(new_item, idx)
	select(idx)

func select(index: int):
	for item in get_children():
		if is_instance_of(item, PaletteItem):
			item.selected = false
	get_child(index).selected = true
	
func queue_repaint():
	$%Controller.call_deferred("render") 
	
func find_selected():
	for item in get_children():
		if is_instance_of(item, PaletteItem) && item.selected:
			return item
	return null
	
func add_span(idx: int, n: int):
	var selected = find_selected()
	if selected != null:
		selected.text = get_parent().raw_text.substr(idx, n)
