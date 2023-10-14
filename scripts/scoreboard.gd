extends VBoxContainer

signal new_sse_event(headers, event, data)
signal connected
signal connection_error(error)

const event_tag = "event:"
const data_tag = "data:"

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
		if child is Control:
			child.queue_free()
	call_deferred("hydrate")
	connect_to_host("ld54.badcop.games", "/event/sse", 443)
	
func connect_to_host(domain : String, url_after_domain : String, port : int = -1):
	self.domain = domain
	self.url_after_domain = url_after_domain
	self.port = port
	self.verify_host = verify_host
	told_to_connect = true

func attempt_to_connect():
	var err = httpclient.connect_to_host(domain, port, TLSOptions.client())
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

func hydrate():
	for user_id in Events.secret_board:
		var score = Events.secret_board.get(user_id, 9999)
		var r = row.instantiate()
		r.id = user_id
		r.score = score
		var r2 = row.instantiate()
		r2.id = user_id
		r2.score = score
		r.buddy = r2
		add_child(r)
		get_owner().add_child(r2)
	var children = get_children()
	for child in children:
		remove_child(child)
	children.sort_custom(
		func(a, b): return a.score < b.score || (a.score == b.score && a.id < b.id)
	)
	for child in children:
		add_child(child)
		
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
		var idx = body.find("\n\n")
		while idx != -1:
			var stuff = get_event_data(body.substr(0, idx))
			var e = stuff.event
			if e == "score" || e == "update":
				var data = stuff.data.split(":")
				var user_id = data[0]
				var score = int(data[1])
				Events.secret_board[user_id] = score
				var skip = false
				for child in get_children():
					if child.id == user_id:
						child.score = score
						skip = true
						break
				if !skip:
					var r = row.instantiate()
					r.id = user_id
					r.score = score
					var r2 = row.instantiate()
					r2.id = user_id
					r2.score = score
					r.buddy = r2
					add_child(r)
					get_owner().add_child(r2)

			response_body = response_body.slice(idx + 2)
			body = response_body.get_string_from_utf8()
			idx = body.find("\n\n")
		var children = get_children()
		for child in children:
			remove_child(child)
		children.sort_custom(
			func(a, b): return a.score < b.score || (a.score == b.score && a.id < b.id)
		)
		for child in children:
			add_child(child)

func get_event_data(body : String):
	var a = body.split("\n")
	var b = a[0].split(": ")[1]
	var c = a[1].split(": ")[1]
	return { "event": b, "data": c }

func _exit_tree():
	if httpclient:
		httpclient.close()
