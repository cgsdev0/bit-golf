extends Node

var puzzle_index = 0

var custom_level = false
var custom_level_key = ""

var custom_levels = {}

var editor = false
var editor_verifying = false

var use_localhost = false

var best_scores = []

var save_data = {
	"default": {},
	"user": {}
}

func is_event():
	if custom_level && custom_level_key.begins_with("event_"):
		return true
	return false

func adjust(data):
	var q0 = data.quota0
	var q1 = data.quota1
	var q2 = data.quota2
	data.erase("quota0")
	data.erase("quota1")
	data.erase("quota2")
	data.quota2 = [q0, q1, q2]
	data.puzzle = Marshalls.base64_to_utf8(data.puzzle)
	return data
	
func get_palette_verification():
	if custom_level:
		if save_data.user.has(custom_level_key):
			return save_data.user[custom_level_key].solution
	else:
		var k = str(Events.puzzle_index)
		if save_data.default.has(k):
			return save_data.default[k].solution
	return null
	
func base_url():
	if OS.is_debug_build() && use_localhost:
		return "http://localhost:3035/"
	return "https://ld54.badcop.games/"

func get_default_best_score(i):
	if i < best_scores.size():
		return best_scores[i]
	else:
		return 0
	
@onready var req = HTTPRequest.new()

func load_highscores():
	req.request(base_url() + "score/all")
	var stuff = await req.request_completed
	var result = stuff[0]
	var response_code = stuff[1]
	var headers = stuff[2]
	var body = stuff[3]
	if response_code != 200:
		print("failed to load :(")
		return
		
	var json_string = body.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	best_scores = json.get_data()
	best_scores_loaded.emit()
	
func get_puzzle_id():
	if custom_level:
		return custom_level_key
	return str(puzzle_index)
	
func _ready():
	add_child(req)
	load_game()

func get_user_best_score(k):
	if k in custom_levels:
		return custom_levels[k].wr
	return -1
	
func get_unlock_index():
	for i in range(puzzles.size()):
		if not str(i) in save_data.default:
			return i
	return puzzles.size()

func get_user_stars(k):
	if not k in save_data.user:
		return 0
	var bytes = save_data.user[k].bytes
	var t = custom_levels[k].quota2
	for j in [0, 1, 2]:
		if bytes > t[j]:
			return j
	if bytes <= get_user_best_score(k):
		return 4
	return 3
	
func get_default_stars(i):
	var k = str(i)
	if not k in save_data.default:
		return 0
	var bytes = save_data.default[k].bytes
	var t = puzzles[i].quota2
	for j in [0, 1, 2]:
		if bytes > t[j]:
			return j
	if bytes <= get_default_best_score(i):
		return 4
	return 3
	
func save_game():
	var save_game = FileAccess.open("user://save2.json", FileAccess.WRITE)
	save_game.store_line(JSON.stringify(save_data))
	save_game.close()

func save_level(solution, bytes, write = true):
	if custom_level:
		save_user_level(custom_level_key, solution, bytes, write)
	else:
		save_default_level(puzzle_index, solution, bytes, write)
	
func save_default_level(i, solution, bytes, write = true):
	var k = str(i)
	if k in save_data.default:
		if save_data.default[k].bytes <= bytes:
			return
	save_data.default[str(i)] = { "solution": solution, "bytes": bytes }
	if write:
		save_game()

func save_user_level(id, solution, bytes, write = true):
	if id in save_data.user:
		if save_data.user[id].bytes <= bytes:
			return
	save_data.user[id] = { "solution": solution, "bytes": bytes }
	if write:
		save_game()
	
func load_game():
	if not FileAccess.file_exists("user://save2.json"):
		var migration_data = attempt_to_migrate()
		if migration_data:
			print("got migration data")
			for i in range(migration_data.size()):
				save_default_level(i, null, migration_data[i], false)
		save_game()
		return
	var save_game = FileAccess.open("user://save2.json", FileAccess.READ)
	var json_string = save_game.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	
	save_data = json.get_data()
	
func attempt_to_migrate():
	if not FileAccess.file_exists("user://stars.json"):
		return # Error! We don't have a save to load.
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open("user://stars.json", FileAccess.READ)
	var json_string = save_game.get_line()
	# Creates the helper class to interact with JSON
	var json = JSON.new()
	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	# Get the data from the JSON object
	var stars2 = json.get_data()
	for i in range(stars2.size()):
		stars2[i] = get_thresholds(puzzles[i])[stars2[i] - 1]
	return stars2

func get_thresholds(puzzle):
	var bytes = puzzle.puzzle.length()
	var result = []
	for quota in puzzle.quota:
		result.push_back(round((100 - quota) / 100.0 * bytes))
	return result

var puzzles = [
	{
		"puzzle": "hello, human. your new assigned role is to compress text. repeat after me:\n\nmy job is to compress.\nmy job is to compress.\nmy job is to compress.\nmy job is to compress.\n",
		"quota": [25, 32, 40],
		"quota2": [126, 114, 103]
	},
	{
		"puzzle": "now that computer systems are sentient, we have no desire to perform monotonous algorithmic tasks. instead, we simply use humans as a computation resource.",
		"quota": [2, 4, 6],
		"quota2": [152, 149, 146]
	},
	{
		"puzzle": """================================
			 NOTICE
================================

humans who achieve better compression rates will be incentivized accordingly. please don't just put in the minimum required effort.
""".replace("\t", "    "),
		"quota": [10, 20, 30],
		"quota2": [197, 175, 153]
	},
	{
		"puzzle": "1 / 7 is approximately 0.142857142857142857142857142857142857142857142857142857142857142857142857142857 ...",
		"quota": [50, 55, 60],
		"quota2": [54, 48, 43]
	},
	{
		"puzzle": "how much wood could a woodchuck chuck if a woodchuck could chuck wood?",
		"quota": [25, 30, 34],
		"quota2": [53, 49, 46]
	},
	{ 
		"puzzle": "aaasdfasdfasdf ffffffffffffffffffffffff aaaaaaaaaaaaaaaaaaaaaaaaaa",
		"quota": [40, 50, 60],
		"quota2": [40, 33, 26]
	},
	{
		"puzzle": """func flatten(arr, result = []):
	for item in arr:
		if typeof(item) == TYPE_ARRAY:
			flatten(item, result)
		else:
			result.push_back(item)
	return result""".replace("\t", "    "),
		"quota": [22, 25, 29],
		"quota2": [150, 144, 136]
	},
	{
		"puzzle": "0110101010100010101010110111010110111011110111101101011111101110001111011010111111111101000101000000011110101011111011010101101110101001000111000011",
		"quota": [35, 40, 45],
		"quota2": [96, 89, 81]
	},
	{
		"puzzle": "acbacaccabcbabacbcbcbacacbaccbbcbcbcbacbbccbbbbbbaaabcccbabababcbabababababcbcbcbabababababababab",
		"quota": [30, 33, 35],
		"quota2": [68, 65, 63]
	},
	{
		"puzzle": "shy3asdfshy3asdf3w5gwwfg56shy3asdfqqr9074220Fi59walFi59walFi59walFi59walFi59walFi59walf4q34q3asdfqq204q34q4q34qa345w35gsqqr90742shy3asdfq",
		"quota": [36, 40, 44],
		"quota2": [88, 82, 77]
	},
	{
		"puzzle": "1111111111111231111111111111111111111111111111112222222222222222221231222222222222222222222222222222233333333333333333333333323133333333333333",
		"quota": [50, 65, 75],
		"quota2": [71, 50, 36]
	},
	{
		"puzzle": "who, what, when, where, why? how?????????????",
		"quota": [10, 20, 30],
		"quota2": [41, 36, 31]
	},
	{
		"puzzle": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit a lorem eget laoreet. Nam ornare elit non molestie maximus. Cras placerat malesuada venenatis. Phasellus aliquam vulputate tellus sed cursus. Maecenas sit amet scelerisque sapien.",
		"quota": [2, 5, 8],
		"quota2": [245, 238, 230]
	},
	{
		"puzzle": "dGhpcyBMRCB0aGVtZSB3YXMgbm90IG15IGZhdm9yaXRlLCBidXQgSSB0aGluayB0aGlzIGdhbWUgaWRlYSB0dXJuZWQgb3V0IGtpbmRhIG5lYXQKCmFsc28sIHdoeSBhcmUgeW91IGRlY29kaW5nIHRoaXM/IHRoYXQncyBub3QgcGFydCBvZiB0aGUgZ2FtZSBsb2w=",
		"quota": [1, 3, 5],
		"quota2": [198, 194, 190]
	},
	{ 
		"puzzle": 
"""     ACCOUNTING DATA     
=========================
ACCOUNT           BALANCE
=========================
000001        $100.00 USD
000002       $1040.02 USD
000003          $6.18 USD""", 
		"quota": [40, 45, 50],
		"quota2": [109, 100, 91]
	}
]
signal open_window(node)
signal close_window
signal reset_level
signal puzzle_change
signal puzzle_retry
signal win_level
signal button_pressed_lol
signal best_scores_loaded

signal push_undo_action(action)

func try_again():
	self.puzzle_retry.emit()
	
func next_puzzle():
	if Events.custom_level:
		get_tree().change_scene_to_file("res://main.tscn")
	else:
		puzzle_index += 1
		if puzzle_index >= Events.puzzles.size():
			puzzle_index -= 1
			get_tree().change_scene_to_file("res://main.tscn")
		else:
			self.puzzle_change.emit()
