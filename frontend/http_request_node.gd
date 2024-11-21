extends HTTPRequest

func _ready():
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request("http://127.0.0.1:8080/generate")
	if error != OK:
		push_error("An error occurred in the HTTP request.")

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Error connecting to server.")
		return

	if response_code != 200:
		push_error("Error: Server returned an unexpected status code %d" % response_code)
		return

	print(body.get_string_from_utf8())
