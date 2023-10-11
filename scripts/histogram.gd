extends Control


var bucket = 0

@onready var Bar = preload("res://scenes/histogram_bar.tscn")

func endpoint():
	if Events.custom_level:
		return "score/user/%s?histogram=true"
	else:
		return "score/%s?histogram=true"
		
func _ready():
	$Spinner/AnimationPlayer.play("spin")
	$HTTPRequest.request_completed.connect(_http_request_completed)
	$HTTPRequest.request(Events.base_url() + endpoint() % Events.get_puzzle_id())
	
func _http_request_completed(result, response_code, headers, body):
	if result != 0 || response_code != 200:
		print("oh no")
		return # anyways
	
	var bars = {}
	var max_freq = 0
	var min_score = 512
	var max_score = 0
	var total_freq = 0
	for line in body.get_string_from_utf8().split("\n"):
		var data = line.strip_edges().split(' ')
		var freq = int(data[0])
		var score = int(data[1])
		if score < min_score:
			min_score = score
		if score > max_score:
			max_score = score
		if freq > max_freq:
			max_freq = freq
		total_freq += freq
		bars[score] = freq
	
	$HSeparator/Label.text = "%.2d" % (max_freq / float(total_freq) * 100.0) + "%"
	$HSeparator.show()
	$Spinner.hide()
	var r = max_score - min_score
	var labeled = [min_score, int(min_score + r * 0.25), int(min_score + r * 0.5), int(min_score + r * 0.75), max_score]
	for i in range(min_score, max_score + 1):
		var child = Bar.instantiate()
		var f = bars.get(i, 0)
		child.height = f / float(max_freq)
		child.score = i
		if bucket == i:
			if f == 0:
				f = 1
				child.height = f / float(max_freq)
			child.set_color(Color.from_string("#f92672", Color.WHITE))
		if not i in labeled:
			child.hide_label()
		$HBoxContainer.add_child(child)
