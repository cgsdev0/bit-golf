extends Node

var puzzle_index = 0

var stars = []

func _ready():
	load_game()

func save_game():
	var save_game = FileAccess.open("user://stars.json", FileAccess.WRITE)
	save_game.store_line(JSON.stringify(stars))

func load_game():
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
	stars = json.get_data()
	
var puzzles = [
	{
		"puzzle": "hello, human. your new assigned role is to compress text. repeat after me:\n\nmy job is to compress.\nmy job is to compress.\nmy job is to compress.\nmy job is to compress.\n",
		"quota": [25, 32, 40]
	},
	{
		"puzzle": "now that computer systems are sentient, we have no desire to perform monotonous algorithmic tasks. instead, we simply use humans as a computation resource.",
		"quota": [2, 4, 6]
	},
	{
		"puzzle": """================================
			 NOTICE
================================

humans who achieve better compression rates will be incentivized accordingly. please don't just put in the minimum required effort.
""".replace("\t", "    "),
		"quota": [10, 20, 30]
	},
	{
		"puzzle": "1 / 7 is approximately 0.142857142857142857142857142857142857142857142857142857142857142857142857142857 ...",
		"quota": [50, 55, 60]
	},
	{
		"puzzle": "how much wood could a woodchuck chuck if a woodchuck could chuck wood?",
		"quota": [25, 30, 34]
	},
	{ 
		"puzzle": "aaasdfasdfasdf ffffffffffffffffffffffff aaaaaaaaaaaaaaaaaaaaaaaaaa",
		"quota": [40, 50, 60]
	},
	{
		"puzzle": """func flatten(arr, result = []):
	for item in arr:
		if typeof(item) == TYPE_ARRAY:
			flatten(item, result)
		else:
			result.push_back(item)
	return result""".replace("\t", "    "),
		"quota": [22, 25, 29]
	},
	{
		"puzzle": "0110101010100010101010110111010110111011110111101101011111101110001111011010111111111101000101000000011110101011111011010101101110101001000111000011",
		"quota": [35, 40, 45]
	},
	{
		"puzzle": "acbacaccabcbabacbcbcbacacbaccbbcbcbcbacbbccbbbbbbaaabcccbabababcbabababababcbcbcbabababababababab",
		"quota": [30, 33, 35]
	},
	{
		"puzzle": "shy3asdfshy3asdf3w5gwwfg56shy3asdfqqr9074220Fi59walFi59walFi59walFi59walFi59walFi59walf4q34q3asdfqq204q34q4q34qa345w35gsqqr90742shy3asdfq",
		"quota": [36, 40, 44]	
	},
	{
		"puzzle": "1111111111111231111111111111111111111111111111112222222222222222221231222222222222222222222222222222233333333333333333333333323133333333333333",
		"quota": [50, 65, 75]
	},
	{
		"puzzle": "who, what, when, where, why? how?????????????",
		"quota": [10, 20, 30]	
	},
	{
		"puzzle": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit a lorem eget laoreet. Nam ornare elit non molestie maximus. Cras placerat malesuada venenatis. Phasellus aliquam vulputate tellus sed cursus. Maecenas sit amet scelerisque sapien.",
		"quota": [2, 5, 8]	
	},
	{
		"puzzle": "dGhpcyBMRCB0aGVtZSB3YXMgbm90IG15IGZhdm9yaXRlLCBidXQgSSB0aGluayB0aGlzIGdhbWUgaWRlYSB0dXJuZWQgb3V0IGtpbmRhIG5lYXQKCmFsc28sIHdoeSBhcmUgeW91IGRlY29kaW5nIHRoaXM/IHRoYXQncyBub3QgcGFydCBvZiB0aGUgZ2FtZSBsb2w=",
		"quota": [1, 3, 5]
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
	}
]
signal open_window(node)
signal close_window
signal reset_level
signal puzzle_change
signal win_level
signal button_pressed_lol

func try_again():
	self.puzzle_change.emit()
	
func next_puzzle():
	puzzle_index += 1
	if puzzle_index >= Events.puzzles.size():
		puzzle_index -= 1
		get_tree().change_scene_to_file("res://main.tscn")
	else:
		self.puzzle_change.emit()
