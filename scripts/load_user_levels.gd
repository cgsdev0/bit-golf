extends Container


# Called when the node enters the scene tree for the first time.
func _ready():
	populate_list()
	if $usr_levels.get_child_count() <= 1:
		$Loading.show()
		$usr_levels.hide()
	else:
		$usr_levels.show()
		$Loading.hide()
	$HTTPRequest.request_completed.connect(_http_request_completed)
	print($HTTPRequest.request(Events.base_url() + "list"))

func _http_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("bad list")
		$Loading.text = "Failed to load :("
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

	$Loading.hide()
	$usr_levels.show()

var cache = {}

var waiting_list = []

func populate_list():
	for level_key in Events.custom_levels:
		var level = Events.custom_levels[level_key]
		var existing = cache.get(level_key)
		if !existing:
			var new_child = preload("res://user_level_item.tscn").instantiate()
			new_child.text = level.name
			new_child.subtitle = "Uploaded on " + level.date
			new_child.likes = level.likes
			new_child.stars = Events.get_user_stars(level_key)
			new_child.level_key = level_key
			cache[level_key] = new_child
			waiting_list.push_back(new_child)
		else:
			existing.likes = level.likes
			existing.stars = Events.get_user_stars(level_key)
			$usr_levels.remove_child(existing)
			waiting_list.push_back(existing)
	
	# yeet the stragglers
	for node in $usr_levels.get_children():
		node.queue_free()
	
	var hsep = HSeparator.new()
	hsep.add_theme_constant_override("separation", 0)
	$usr_levels.add_child(hsep)
	
	# lets sort
	waiting_list.sort_custom(
		func(a, b): return a.likes < b.likes
	)
	
	for item in waiting_list:
		hsep = HSeparator.new()
		hsep.add_theme_constant_override("separation", 0)
		$usr_levels.add_child(item)
		$usr_levels.add_child(hsep)
		
	waiting_list.clear()
		
func _process(delta):
	pass
