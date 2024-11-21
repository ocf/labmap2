'''
This script controls the background by turning the alpha level of the BackgroundLight
node to 1 between 8am and 8pm and to 0 outside of those times.
'''

extends Sprite2D

@export var day_start = 8  # 8 AM
@export var night_start = 20  # 8 PM
@export var fade_duration = 2.0  # Duration of fade in seconds

var target_alpha = 1.0  # The desired alpha value for the light background

func _ready():
	# Set the initial alpha value based on the current time
	update_target_alpha()
	self.modulate.a = target_alpha

func _process(_delta):
	# Smoothly adjust alpha value to the target
	self.modulate.a = lerp(self.modulate.a, target_alpha, 0.1)
	# Periodically check the time to update target alpha values
	if Time.get_datetime_dict_from_system().second == 0:  # Check every minute
		update_target_alpha()

func update_target_alpha():
	var time = Time.get_datetime_dict_from_system()  # Get current local time
	var hour = time.hour
	if hour >= night_start or hour < day_start:
		target_alpha = 0.0  # Nighttime: fade out
	else:
		target_alpha = 1.0  # Daytime: fade in
