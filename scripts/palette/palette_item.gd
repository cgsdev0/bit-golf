class_name PaletteItem extends Control


@export var text: String = "":
	set (value):
		text = value
		$PaletteItem/Label.text = value.replace('\n', '↲').replace(' ', '\u23b5')
		
@export var color: Color = Color.WHITE:
	set (value):
		color = value
		$PaletteItem/HBoxContainer/Sprite2D.self_modulate = value
		
var disabled: bool = false :
	set (value):
		disabled = value
		if value:
			%Label.modulate = Color(1,1,1,0.3)
			$Selected.modulate = Color(1,1,1,0.5)
			$PaletteItem/HBoxContainer/Sprite2D.self_modulate.a = 0.5
		else:
			%Label.modulate = Color.WHITE
			$Selected.modulate = Color.WHITE
			$PaletteItem/HBoxContainer/Sprite2D.self_modulate.a = 1.0
		update_sprite()
			
var rle: bool = false:
	set (value):
		rle = value
		update_sprite()
		
var matched: bool = false

@export var selected: bool = false:
	set (value):
		selected = value
		$Selected.visible = value
		if selected:
			$PaletteItem.mouse_default_cursor_shape = CURSOR_MOVE
		else:
			$PaletteItem.mouse_default_cursor_shape = CURSOR_ARROW
		
var dragging = false
var drag_offset = Vector2.ZERO
var offset_offset = Vector2.ZERO
var drag_start_index = -1
	
func update_sprite():
	$PaletteItem/HBoxContainer/Sprite2D.texture.region.position.x = 19 if disabled else 0
	$PaletteItem/HBoxContainer/Sprite2D.texture.region.position.y = 19 if rle else 0
	
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
			if drag_start_index != get_index():
				Events.push_undo_action.emit({"action": Undo.Action.MOVE_COLOR, "from": drag_start_index, "to": get_index()})
			dragging = false

func toggle_rle():
	rle = !rle
	$RLE.play()
	if rle:
		$RMBHint.hide()
	get_parent().queue_repaint()
	print("i did a toggle ", rle)
	
func toggle_disabled():
	disabled = !disabled
	$RLE.play()
	get_parent().queue_repaint()
	
func _gui_input(event):
	if event is InputEventMouseButton && event.button_index == 2 && event.is_pressed():
		accept_event()
		toggle_rle()
		Events.push_undo_action.emit({ "action": Undo.Action.TOGGLE_RLE, "index": get_index()})
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		dragging = true
		drag_start_index = get_index()
		drag_offset = get_global_mouse_position()
		accept_event()
		get_parent().select(get_index())
	


func _on_delete_pressed():
	Events.push_undo_action.emit({ "action": Undo.Action.DELETE_COLOR, "index": get_index(), "text": text, "disabled": disabled, "rle": rle })
	delete_me()


func _on_sprite_2d_gui_input(event):
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		accept_event()
		toggle_disabled()
		Events.push_undo_action.emit({ "action": Undo.Action.TOGGLE_DISABLE, "index": get_index()})

func _ready():
	%Outline.modulate = Color.TRANSPARENT


func _on_sprite_2d_2_mouse_entered():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	%Outline.modulate = Color.WHITE


func _on_sprite_2d_2_mouse_exited():
	%Outline.modulate = Color.TRANSPARENT
