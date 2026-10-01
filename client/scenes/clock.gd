extends RichTextLabel

@export var font_size: int = 40
@export var font_color: Color = Color.BLACK
@export var update_interval: float = 1.0 # seconds

var timer: Timer

func _ready():
	bbcode_enabled = true  # allow BBCode formatting

	# Apply font overrides
	add_theme_color_override("default_color", font_color)
	add_theme_font_size_override("normal_font_size", font_size)

	# Setup timer
	timer = Timer.new()
	timer.wait_time = update_interval
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_update_time)

	_update_time() # show immediately on start

func _update_time():
	var now = Time.get_datetime_dict_from_system()
	# Weekday and month names
	var weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
	var months = ["January", "February", "March", "April", "May", "June", "July",
				  "August", "September", "October", "November", "December"]
	var weekday_name = weekdays[now.weekday - 1]  # weekday: 1=Monday, 7=Sunday
	var month_name = months[now.month - 1]
	# Day with ordinal suffix
	var day = now.day
	var ordinal = "th"
	if day % 10 == 1 and day != 11:
		ordinal = "st"
	elif day % 10 == 2 and day != 12:
		ordinal = "nd"
	elif day % 10 == 3 and day != 13:
		ordinal = "rd"
	# 12-hour clock
	var hour = now.hour % 12
	if hour == 0:
		hour = 12
	var am_pm = "AM" if now.hour < 12 else "PM"
	var date_str = "[right]\n%s %s %d%s, %d\n%d:%02d:%02d %s[/right]" % [
		weekday_name, month_name, day, ordinal, now.year,
		hour, now.minute, now.second, am_pm
	]

	clear()
	
	var bbcode_text = ""
	if has_node("HttpGetLabHours"):
		var http_node = $HttpGetLabHours
		bbcode_text = "[color=%s]%s\n%s[/color]" % [
			font_color.to_html(false), date_str, http_node.bbcode_snippet
		]
	push_color(font_color)
	append_text(bbcode_text)
	pop()
