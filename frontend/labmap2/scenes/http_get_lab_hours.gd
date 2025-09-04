extends HTTPRequest

signal hours_ready(hours: Dictionary)

@onready var parser = YAMLParser.new()
@onready var refresh_timer := Timer.new()
var bbcode_snippet: String = ""  # this will hold the formatted opening hours

func _ready():
	request_completed.connect(_on_request_completed)

	# Add a timer for periodic refresh
	refresh_timer.wait_time = 600 # 10 minutes
	refresh_timer.autostart = true
	refresh_timer.one_shot = false
	refresh_timer.timeout.connect(_on_refresh_timer_timeout)
	add_child(refresh_timer)
	# Initial fetch
	_request_hours()

func _request_hours():
	var url = "https://labmap.ocf.berkeley.edu/api/hours"
	request(url)

func _on_refresh_timer_timeout():
	_request_hours()

func _on_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		push_error("Failed to fetch YAML: %s" % response_code)
		return
	var yaml_text = body.get_string_from_utf8()
	var parsed = parser.parse(yaml_text)
	if typeof(parsed) == TYPE_DICTIONARY:
		emit_signal("hours_ready", parsed)
	else:
		push_error("YAML did not parse into a dictionary")
		return

	# Grab just the regular hours
	if parsed.has("regular"):
		bbcode_snippet = build_regular_hours_bbcode(parsed["regular"])

func build_regular_hours_bbcode(regular_dict: Dictionary) -> String:
	var snippet = ""
	# Get today's weekday
	var now = Time.get_datetime_dict_from_system()
	var weekday_index = now.weekday  # 1 = Monday, 7 = Sunday
	var weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
	var today_name = weekdays[weekday_index - 1]
	# Get today's hours
	var hours_list = regular_dict.get(today_name, null)
	if hours_list == null:
		snippet += "[right]%s: Closed[/right]\n" % today_name
	else:
		var hours_str = ""
		for range in hours_list:
			var start_am_pm = _convert_to_ampm(range[0])
			var end_am_pm = _convert_to_ampm(range[1])
			hours_str += "%s – %s, " % [start_am_pm, end_am_pm]
		hours_str = hours_str.rstrip(", ")
		snippet += "[right]Today's Hours: %s[/right]\n" % hours_str
	return snippet
	
func _convert_to_ampm(time_str: String) -> String:
	var parts = time_str.split(":")
	var hour = int(parts[0])
	var minute = parts[1]
	var am_pm = "AM"
	if hour == 0:
		hour = 12
	elif hour == 12:
		am_pm = "PM"
	elif hour > 12:
		hour -= 12
		am_pm = "PM"
	return "%d:%s %s" % [hour, minute, am_pm]
