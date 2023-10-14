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
	initted = true
	if buddy:
		# item_rect_changed.connect(buddy.wtf.bind(self))
		buddy.hide()
		# oof
		await get_tree().create_timer(0.1).timeout
		buddy.init(self)
		buddy.show()
		modulate = Color.TRANSPARENT
		
var initted = false
var par = null

func init(par):
	self.par = par
	size = par.size
	global_position = par.global_position
	z_index = 15 - par.get_index()
	
var tweening = false

func _process(delta):
	
	if par == null || tweening:
		return
	
	size = par.size
	if par.global_position == global_position:
		return
	
	var tween = get_tree().create_tween()
	z_index = 15 - par.get_index()
	tween.tween_property(self, "global_position", par.global_position, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tweening = true
	await tween.finished
	tweening = false
