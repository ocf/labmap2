'''
This script manages the requests and data coming from the data_generator_server.
It sends two requests to the endpoints of the data generator, one receiving processed
data from Prometheus and another receiving data from the user-controlled API.
They are result_from_generate and result_from_get respectively.
In order to get these seperate requests, meta data is used to organize the results.
Some really bad code is used to query the http_request children of their data, but
if you can overlook that, it works fine.
'''

extends HTTPRequest

@onready var result_from_generate: Dictionary = {}
@onready var result_from_get: Dictionary = {}

var GENERATE;
var GET;
var env_vars = {};

signal result_ready(endpoint: String)

var flipflop = 1 # don't ask

func _ready():
	load_env("res://.env")
	GENERATE = env_vars["GENERATE_URI"]
	GET = env_vars["GET_URI"]
	_send_http_request(GENERATE)
	_send_http_request(GET)

func _send_http_request(url: String) -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.set_meta("endpoint", url)  # Store the endpoint as metadata
	http_request.request_completed.connect(self._http_request_completed)

	var error = http_request.request(url) # Send the request
	if error != OK:
		Logger.log("An error occurred in the HTTP request.", "Error", "DATA_GENERATOR")

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, _headers, body):
	var endpoint: String
 	# this is some awful code, god forgive me
	if flipflop == 1:
		endpoint = get_child(2).get_meta("endpoint")
	elif flipflop == -1:
		endpoint = get_child(1).get_meta("endpoint")
	flipflop = flipflop * -1

	if result != HTTPRequest.RESULT_SUCCESS:
		Logger.log("Error connecting to data generator server", "Error", "DATA_GENERATOR")
		return
	if response_code != 200:
		Logger.log("Error: Server returned an unexpected status code %d" % response_code, "Error", "DATA_GENERATOR")
		return

	var parsedResult = JSON.parse_string(body.get_string_from_utf8())
	if parsedResult is Dictionary:
		if endpoint == GENERATE:
			result_from_generate = parsedResult
		elif endpoint == GET:
			result_from_get = parsedResult
		emit_signal("result_ready", endpoint)
	else:
		#print("Error Reading File")
		Logger.log("Error reading data generator response", "Error", "DATA_GENERATOR")

func _on_update_timer_timeout() -> void:
	_ready()
	
func load_env(path: String):
	if not FileAccess.file_exists(path):
		push_warning(".env file not found at " + path)
		return
	
	var file = FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "" or line.begins_with("#"): # skip comments/empty
			continue
		var parts = line.split("=", true, 1)
		if parts.size() == 2:
			env_vars[parts[0].strip_edges()] = parts[1].strip_edges()
