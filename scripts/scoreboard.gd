extends VBoxContainer

signal new_sse_event(headers, event, data)
signal connected
signal connection_error(error)

const event_tag = "event:"
const data_tag = "data:"
const continue_internal = "continue_internal"

var httpclient = HTTPClient.new()
var is_connected = false

var domain
var url_after_domain
var port
var use_ssl
var verify_host
var told_to_connect = false
var connection_in_progress = false
var request_in_progress = false
var is_requested = false
var response_body = PackedByteArray()

@onready var row = preload("res://scenes/scoreboard_row.tscn")
func _ready():
	for child in get_children():
		child.queue_free()
	connect_to_host("localhost", "/event/sse", 3035)
	
func connect_to_host(domain : String, url_after_domain : String, port : int = -1):
	self.domain = domain
	self.url_after_domain = url_after_domain
	self.port = port
	self.verify_host = verify_host
	told_to_connect = true

func attempt_to_connect():
	var err = httpclient.connect_to_host(domain, port)
	if err == OK:
		emit_signal("connected")
		is_connected = true
	else:
		emit_signal("connection_error", str(err))
		print(err)

func attempt_to_request(httpclient_status):
	if httpclient_status == HTTPClient.STATUS_CONNECTING or httpclient_status == HTTPClient.STATUS_RESOLVING:
		return
		
	if httpclient_status == HTTPClient.STATUS_CONNECTED:
		var err = httpclient.request(HTTPClient.METHOD_GET, url_after_domain, ["Accept: text/event-stream"])
		if err == OK:
			is_requested = true

func _physics_process(delta):
	if !told_to_connect:
		return
		
	if !is_connected:
		if !connection_in_progress:
			attempt_to_connect()
			connection_in_progress = true
		return
		
	httpclient.poll()
	var httpclient_status = httpclient.get_status()
	if !is_requested:
		if !request_in_progress:
			attempt_to_request(httpclient_status)
		return
		
	var httpclient_has_response = httpclient.has_response()
		
	if httpclient_has_response:
		var headers = httpclient.get_response_headers_as_dictionary()
	if httpclient_status == HTTPClient.STATUS_BODY:
		

		httpclient.poll()
		var chunk = httpclient.read_response_body_chunk()
		if(chunk.size() == 0):
			return
		else:
			response_body = response_body + chunk
		var body = response_body.get_string_from_utf8()
		response_body.resize(0)
		var events = body.split("\n\n", false)
		for event in events:
			var stuff = event.split("\n")
			print(stuff)
			var e = stuff[0].split(": ")[1]
			if e == "score":
				var data = stuff[1].split(": ")[1].split(":")
				var user_id = data[0]
				var score = int(data[1])
				var r = row.instantiate()
				r.id = user_id
				r.score = score
				var r2 = row.instantiate()
				r2.id = user_id
				r2.score = score
				r.buddy = r2
				add_child(r)
				get_owner().add_child(r2)
			if e == "update":
				var data = stuff[1].split(": ")[1].split(":")
				var user_id = data[0]
				var score = int(data[1])
				for child in get_children():
					if child.id == user_id:
						child.score = score
		var children = get_children()
		for child in children:
			remove_child(child)
		children.sort_custom(
			func(a, b): return a.score < b.score || (a.score == b.score && a.id < b.id)
		)
		for child in children:
			add_child(child)

func get_event_data(body : String) -> Dictionary:
	var result = {}
	var event_idx = body.find(event_tag)
	if event_idx == -1:
		result["event"] = continue_internal
		return result
	assert(event_idx != -1)
	var data_idx = body.find(data_tag, event_idx + event_tag.length())
	assert(data_idx != -1)
	var event = body.substr(event_idx, data_idx)
	event = event.replace(event_tag, "").strip_edges()
	assert(event)
	assert(event.length() > 0)
	result["event"] = event
	var data = body.right(data_idx + data_tag.length()).strip_edges()
	assert(data)
	assert(data.length() > 0)
	result["data"] = data
	return result

func _exit_tree():
	if httpclient:
		httpclient.close()
