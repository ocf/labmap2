extends Node2D

var devices_array
var waddles_active_devices = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_waddles_if_logged_in()

func spawn_waddles_if_logged_in():
	devices_array = get_node("Devices").devices # Reference the devices array
	for device in devices_array:
		if device.logged_in == "yes" and device.name not in waddles_active_devices.keys():
			var waddles_instance = preload("res://waddles.tscn").instantiate()
			add_child(waddles_instance)
			waddles_instance.set_target_desktop(device.name)
			waddles_active_devices[device.name] = waddles_instance
			
		elif device.logged_in != "yes" and device.name in waddles_active_devices.keys():
			waddles_active_devices[device.name].walk_back_to_door()
			waddles_active_devices.erase(device.name)

func _on_update_timer_timeout() -> void:
	spawn_waddles_if_logged_in()
