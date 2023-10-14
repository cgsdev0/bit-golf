extends Control

@export var id: String = "":
	set (value):
		id = value
		%Name.text = Events.event_players.get(id, "unknown")[0]
		%Avatar.texture = Events.event_players.get(id, "unknown")[1]
		if buddy:
			buddy.id = value
		
@export var score: int = 0:
	set (value):
		score = value
		%Score.text = str(score)
		if buddy:
			buddy.score = value
		elif initted:
			$AnimationPlayer.play("move_up")
		
var buddy: Control

func _ready():
	if buddy:
		item_rect_changed.connect(buddy.wtf.bind(self))
		buddy.hide()
		# oof
		await get_tree().create_timer(0.5).timeout
		buddy.init(self)
		buddy.show()
		modulate = Color.TRANSPARENT
		
var initted = false

func init(par):
	initted = true
	global_position = par.global_position
	z_index = 15 -par.get_index()
	
func wtf(par):
	size = par.size
	
	if !initted:
		return
	var tween = get_tree().create_tween()
	z_index = -par.get_index()
	tween.tween_property(self, "global_position", par.global_position, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
