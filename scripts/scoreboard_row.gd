extends Control

var players = {	
	"533316027883323402": "Ausstein",
	"559761186254487573": "icylava",
	"132132767646482432": "underyx",
	"522918310958858286": "kuviman",
	"158651343391686657": "MarkAis",
	"110534413015633920": "Meep",
	"459020091917467648": "Pomo",
	"701939869420617732": "rickylee",
	"431090395653341197": "schadocalex",
	"363257423865053184": "tron"
}
@export var id: String = "":
	set (value):
		id = value
		%Name.text = players[id]
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
		await get_tree().create_timer(0.1).timeout
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
