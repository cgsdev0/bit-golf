extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.custom_levels = {}
	$HTTPRequest.request_completed.connect(_http_request_completed)
	$HTTPRequest.request(Events.base_url() + "event/list")

func _http_request_completed(result, response_code, headers, body):
	if result != 0 || response_code != 200:
		print("bad list")
		return
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", body.get_string_from_utf8(), " at line ", json.get_error_line())
		return

	# Get the data from the JSON object
	var arr = json.get_data()
	if not arr is Array:
		print("not array")
		return
	
	for level in arr:
		Events.custom_levels[level.id] = Events.adjust(level)
	
	populate_list()

var cache = {}

var waiting_list = []

@onready var grid = %GridContainer

func populate_list():
	var i = 0
	for level_key in Events.custom_levels:
		var level = Events.custom_levels[level_key]
		var btn = grid.get_child(i)
		btn.text = level.name
		btn.level_key = level.id
		btn.wr = level.wr
		btn.raw = level.raw_size
		btn.cooked = Events.save_data.get(level.id, {}).get("bytes", level.raw_size)
		i += 1
		
func _process(delta):
	pass
