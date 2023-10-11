class_name ButtonJuice extends BaseButton


@onready var player = AudioStreamPlayer.new()
@onready var player2 = AudioStreamPlayer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	self.mouse_entered.connect(on_enter)
	self.pressed.connect(on_press)
	player.stream = preload("res://sounds/hover2.wav")
	player.volume_db = -5.0
	add_child(player)

func on_press():
	Events.button_pressed_lol.emit()
	
func on_enter():
	if !disabled:
		player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
