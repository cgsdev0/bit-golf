@tool
extends Node2D



@export var dimensions : Vector2
@export var color : Color = Color.WHITE
@export var bg_color : Color = Color.WHITE
@export var title : String
@export var closable : bool

var title_height = 24
var font

var title_color

var focused

var focused_color = Color.BLACK
var unfocused_color = Color("#4f4f4f")

func focus():
	focused = true
	queue_redraw()

func blur():
	focused = false
	queue_redraw()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	focused = false
	font = load("res://fonts/PixelOperatorMono.ttf")

func _process(delta):
	if !font:
		font = load("res://fonts/PixelOperatorMono.ttf")
	
	$Body.size = dimensions
	# title bar
	$Body/Title.size.y = title_height
	$Body/Title.size.x = dimensions.x
	
func draw_round_rect(rect: Rect2, color: Color):
	var w = Vector2(1, 0)
	var h = Vector2(0, 1)
	var pos = rect.position
	var size = rect.size
	draw_line(pos, pos + size * w - w, color)
	draw_line(pos + h, pos + size * h, color)
	draw_line(pos + size * w + h, pos + size, color)
	draw_line(pos + size * h, pos + size - w, color)

func lighten(color: Color):
	return Color.DARK_GRAY
	
func _draw():
	var nudge = Vector2(1, 0)
	var shadow_color = Color(0,0,0, 0.1)
	draw_rect(Rect2(Vector2(6,6), dimensions - nudge), shadow_color)
	draw_rect(Rect2(Vector2(0,0), dimensions - nudge), bg_color)
	
	title_color = color
	var border_color = unfocused_color
	if focused:
		border_color = focused_color
	else:
		title_color = lighten(color)
		
	draw_rect(Rect2(Vector2(0,0), Vector2(dimensions.x, title_height) - nudge), title_color)
	draw_line(Vector2(0, title_height), Vector2(dimensions.x,title_height), border_color)
	draw_round_rect(Rect2(Vector2(0,0), dimensions), border_color)
	draw_string(font, Vector2(floor(dimensions.x / 2 - font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 32.0).x / 2), title_height - 3), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 32.0, Color.WHITE)
