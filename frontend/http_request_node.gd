extends HTTPRequest

@onready var prometheus_result: Dictionary = {}

signal result_ready

func _ready():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	var error = http_request.request("http://127.0.0.1:8080/generate") # Currently setup for test environment
	if error != OK:
		#push_error("An error occurred in the HTTP request.")
		Logger.log("An error occurred in the HTTP request.", "Error", "DATA_GENERATOR")

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		#push_error("Error connecting to server.")
		Logger.log("Error connecting to data generator server", "Error", "DATA_GENERATOR")
		return

	if response_code != 200:
		#push_error("Error: Server returned an unexpected status code %d" % response_code)
		Logger.log("Error: Server returned an unexpected status code %d" % response_code, "Error", "DATA_GENERATOR")
		return

	var parsedResult = JSON.parse_string(body.get_string_from_utf8())
	if parsedResult is Dictionary:
		prometheus_result = parsedResult
		emit_signal("result_ready")
	else:
		#print("Error Reading File")
		Logger.log("Error reading data generator response", "Error", "DATA_GENERATOR")

func _on_update_timer_timeout() -> void:
	_ready()
