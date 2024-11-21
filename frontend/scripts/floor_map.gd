'''
This script is the root script of the labmap2 frontend. This means it runs before
all the other scripts in this project, keep this in mind when accessing data in
other scripts as it may have to be instantiated first.
This script is primarily an operator for the Waddles scene. It does this by
accessing the Devices array created in devices.gd and assigning it to devices_array,
then parsing that information and spawning Waddles' based on conditions.
Similar to the devices.gd script, it checks Update_Timer to keep information up-to-date.
'''

extends Node2D

var devices_array
var waddles_active_devices = {}

func _ready():
	spawn_waddles_if_logged_in()

func spawn_waddles_if_logged_in():
	# Called by ready(), _on_update_timer_timeout()
	devices_array = get_node("Devices").devices
	for device in devices_array:
		if device.logged_in == "yes" and device.name not in waddles_active_devices.keys():
			var waddles_instance = preload("res://scenes/waddles.tscn").instantiate()
			add_child(waddles_instance)
			waddles_instance.set_target_desktop(device.name)
			waddles_active_devices[device.name] = waddles_instance
			Logger.log("User '%s' logged in" % device.user, "waddles", device.name)
			
		elif device.logged_in != "yes" and device.name in waddles_active_devices.keys():
			waddles_active_devices[device.name].walk_back_to_door()
			Logger.log("User '%s' logged out" % device.user, "waddles", device.name)
			waddles_active_devices.erase(device.name)

func _on_update_timer_timeout() -> void:
	spawn_waddles_if_logged_in()
