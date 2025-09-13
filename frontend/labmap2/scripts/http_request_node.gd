'''
This script manages the requests and data coming from the data_generator_server.
It sends two requests to the endpoints of the data generator, one receiving processed
data from Prometheus and another receiving data from the user-controlled API.
They are result_from_generate and result_from_get respectively.
'''

extends HTTPRequest

@onready var http_generate := HTTPRequest.new()
@onready var http_get := HTTPRequest.new()
@onready var update_timer := Timer.new()

@onready var result_from_generate: Dictionary = {}
@onready var result_from_get: Dictionary = {}

const GENERATE = "https://labmap.ocf.berkeley.edu/api/generate"
const GET = "https://labmap.ocf.berkeley.edu/api/get"

signal result_ready(endpoint: String)

func _ready():
	add_child(http_generate)
	add_child(http_get)
	
	http_generate.request_completed.connect(_on_generate_completed)
	http_get.request_completed.connect(_on_get_completed)
	
	update_timer.wait_time = 5.0  # 5 seconds
	update_timer.one_shot = false
	update_timer.timeout.connect(_on_update_timer_timeout)
	add_child(update_timer)

	_send_http_request(http_generate, GENERATE)
	_send_http_request(http_get, GET)

func _send_http_request(http_request: HTTPRequest, url: String) -> void:
	var headers = [
		"Accept: application/json",
		"Accept-Encoding: identity"
	]
	var error = http_request.request(url, headers)
	if error != OK:
		Logger.log("An error occurred in the HTTP request.", "Error", "DATA_GENERATOR")

# Called when the HTTP request is completed.
func _on_generate_completed(result, response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		Logger.log("Error in generate request", "Error", "DATA_GENERATOR")
		return

	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if parsed is Dictionary:
		result_from_generate = parsed
		emit_signal("result_ready", GENERATE)
	else:
		Logger.log("Error parsing generate response", "Error", "DATA_GENERATOR")
	update_timer.start() 

func _on_get_completed(result, response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		Logger.log("Error in get request", "Error", "DATA_GENERATOR")
		return

	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if parsed is Dictionary:
		result_from_get = parsed
		emit_signal("result_ready", GET)
	else:
		Logger.log("Error parsing get response", "Error", "DATA_GENERATOR")
		
func _on_update_timer_timeout() -> void:
	var generate_status = http_generate.get_http_client_status()
	var get_status = http_generate.get_http_client_status()
	if generate_status in [0, 5]:
		_send_http_request(http_generate, GENERATE)
	if get_status in [0, 5]:
		_send_http_request(http_get, GET)
