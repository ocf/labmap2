'''
This script controls the background by turning the alpha level of the BackgroundLight
node to 1 between 8am and 8pm and to 0 outside of those times.
It reads a signal from the HttpGetLabHours to determine if the background light is on or not.
'''

extends Sprite2D

@export var fade_duration = 2.0  # Duration of fade in seconds
var target_alpha = 1.0  # The desired alpha value for the light background
var today_hours: Array = []

func _ready():
	# Set the initial alpha value based on the current time
	update_target_alpha()
	self.modulate.a = target_alpha

func _process(_delta):
	# Smoothly adjust alpha value to the target
	self.modulate.a = lerp(self.modulate.a, target_alpha, 0.1)
	# Check once per minute
	if Time.get_datetime_dict_from_system().second == 0:
		update_target_alpha()


func update_target_alpha():
	var now = Time.get_datetime_dict_from_system()
	var current_minutes = now.hour * 60 + now.minute

	if today_hours.is_empty():
		# Fallback: treat as always closed = dark
		target_alpha = 0.0
		return

	var open_now = false
	for range in today_hours:
		var open_split = range[0].split(":")
		var close_split = range[1].split(":")
		var open_minutes = int(open_split[0]) * 60 + int(open_split[1])
		var close_minutes = int(close_split[0]) * 60 + int(close_split[1])

		if current_minutes >= open_minutes and current_minutes < close_minutes:
			open_now = true
			break

	target_alpha = 1.0 if open_now else 0.0

func _on_http_get_lab_hours_hours_ready(hours: Dictionary) -> void:
	var days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
	var now = Time.get_datetime_dict_from_system()
	var day_name = days[now.weekday]
	today_hours = hours["regular"].get(day_name, [])
	update_target_alpha()
