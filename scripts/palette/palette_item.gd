class_name PaletteItem extends Control


@export var text: String = "":
	set (value):
		text = value
		$PaletteItem/Label.text = value.replace('\n', '↲').replace(' ', '\u23b5')
		
@export var color: Color = Color.WHITE:
	set (value):
		color = value
		$PaletteItem/HBoxContainer/Sprite2D.modulate = value
		
var rle: bool = false:
	set (value):
		rle = value
		if rle:
			$PaletteItem/HBoxContainer/Sprite2D.texture = rle_sprite
		else:
			$PaletteItem/HBoxContainer/Sprite2D.texture = default_sprite
		
var matched: bool = false

@export var selected: bool = false:
	set (value):
		selected = value
		$Selected.visible = value

var rle_sprite = preload("res://sprites/circle_rle.png")
var default_sprite = preload("res://sprites/circle.png")

var dragging = false
var drag_offset = Vector2.ZERO
var offset_offset = Vector2.ZERO
	
func delete_me():
	accept_event()
	var old_idx = get_index()
	var old_parent = get_parent()
	get_parent().return_color(self.color)
	get_parent().queue_repaint()
	get_parent().remove_child(self)
	old_parent.select(old_idx)
	queue_free()
	
var shown = false

func flash_hint():
	shown = true
	$RMBHint.show()
	$RMBHint/AnimationPlayer.play("flash")
	
func _process(delta):
	if Events.puzzle_index != 2 || Events.get_unlock_index() > 2:
		return
	if text.contains("=") && !shown:
		flash_hint()
		
func _input(event):
	if event is InputEventMouseMotion && dragging:
		var diff = (get_global_mouse_position() - drag_offset).y
		if abs(diff) > get_rect().size.y:
			var target_slot = get_index() + (sign(diff) * floor(abs(diff / float(get_rect().size.y))))
			if target_slot < 0 || target_slot >= get_parent().get_child_count() - 1:
				return
			get_parent().move_child(self, target_slot)
			get_parent().play_pop()
			get_parent().queue_repaint()
			drag_offset.y = get_global_mouse_position().y
	if event is InputEventMouseButton && event.button_index == 1 && event.is_released():
		if dragging:
			dragging = false
		
func _gui_input(event):
	if event is InputEventMouseButton && event.button_index == 2 && event.is_pressed():
		accept_event()
		rle = !rle
		$RLE.play()
		if rle:
			$RMBHint.hide()
		get_parent().queue_repaint()
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		dragging = true
		
		drag_offset = get_global_mouse_position()
		accept_event()
		get_parent().select(get_index())
	


func _on_delete_pressed():
	delete_me()
