class_name Undo extends Node


var undo_stack = []
var redo_stack = []

enum Action {
	DELETE_COLOR,
	TOGGLE_RLE,
	TOGGLE_DISABLE,
	NEW_COLOR,
	SELECT_TEXT,
	MOVE_COLOR
}

func undo():
	var result = undo_stack.pop_back()
	if result:
		redo_stack.push_back(result)
	return result

func redo():
	var result = redo_stack.pop_back()
	if result:
		undo_stack.push_back(result)
	return result
	
func push_action(action):
	undo_stack.push_back(action)
	redo_stack = []
	
func reset():
	undo_stack = []
	redo_stack = []
	
func _ready():
	Events.puzzle_change.connect(reset)
	Events.push_undo_action.connect(push_action)
	
func apply(action, forward):
	if !action:
		return
	match action.action:
		Action.TOGGLE_RLE:
			%Palette.get_child(action.index).toggle_rle()
		Action.TOGGLE_DISABLE:
			%Palette.get_child(action.index).toggle_disabled()
		Action.MOVE_COLOR:
			if forward:
				%Palette.move_child(%Palette.get_child(action.from), action.to)
			else:
				%Palette.move_child(%Palette.get_child(action.to), action.from)
			%Palette.play_pop()
			%Controller.render()
		Action.SELECT_TEXT:
			if forward:
				%Palette.change_text(%Palette.get_child(action.index), action.new)
			else:
				%Palette.change_text(%Palette.get_child(action.index), action.old)
			%Controller.render()
		Action.NEW_COLOR:
			if forward:
				%Palette.new_color()
			else:
				%Palette.get_child(action.index).delete_me()
		Action.DELETE_COLOR:
			if forward:
				%Palette.get_child(action.index).delete_me()
			else:
				%Palette.restore_color(action.text, action.rle, action.disabled, action.index)
			
func _input(event):
	if Events.editor && !Events.editor_verifying:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	if event.is_action_pressed("ui_redo"):
		apply(redo(), true)
	elif event.is_action_pressed("ui_undo"):
		apply(undo(), false)
	
	
	
