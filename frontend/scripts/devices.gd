'''
This script assigns data and identification to the devices on the Devices tilemaplayer.
It does this by querying information from data_generator.py (or sample_data.json)
and assigning it via the names_dictionary.json, which contains a list of the device
coordinates as they appear on the tilemaplayer and their corresponding names.
After this, it assigns additional information such as the device's on/off status,
the device's logged-in status, and the user which is logged in.
Finally, based on the Update_Timer node in the floor_map scene, it re-queries this
information so that all the devices and their information remains up-to-date.
'''

extends TileMapLayer

const NamesDictionary = "res://name_dictionary.json"
const SampleData = "res://sample_data.json"

var device_coordinates = {}
var sample_data = {}
var data = {}

@onready var devices = populate_blank_desktops()
@onready var update_timer = Timer.new()

func _ready():
	device_coordinates = convert_keys_to_vector2i(load_json_file(NamesDictionary))
	assign_names_to_desktops(devices)
	populate_devices(load_json_file(SampleData))
	#populate_devices(data)
	Logger.log("Devices array populated", "status_change", "ALL_DEVICES")
	update_desktop_displays()

func _process(_delta):
	pass

func populate_blank_desktops() -> Array:
	# Called by ready()
	var desktops = []
	var tile_coords = get_used_cells()
	
	for coord in tile_coords:
		var atlas_coords = get_cell_atlas_coords(Vector2i(coord))
		#var status = get_status_from_atlas(atlas_coords)
		var desktop = Device.new("Default", coord, atlas_coords, "No Status Assigned", "No logged_in status", "No User")
		desktops.append(desktop)
		
	Logger.log("Devices array initalized", "status_change", "ALL_DEVICES")
	return desktops
	
func assign_names_to_desktops(devices_var: Array):
	# Called by ready()
	for device in devices_var:
		var coord = device.coordinates
		if coord in device_coordinates.keys():
			# Assign the name from the dictionary
			device.name = device_coordinates[coord]
	Logger.log("Devices array names assigned", "status_change", "ALL_DEVICES")

func populate_devices(data_var: Dictionary):
	# Called by ready() and _on_update_timer_timeout()
	# Get the 'desktops' array from the JSON
	var desktops_array = data_var.get("desktops", [])

	for desktop_data in desktops_array:
		var json_name = desktop_data.get("name", "")
		var matched_device = find_device_by_name(json_name)
		
		# If a matching device is found, update its properties
		if matched_device != null:
			matched_device.status = desktop_data.get("status", "")
			matched_device.logged_in = desktop_data.get("logged_in", "")
			matched_device.user = desktop_data.get("user", "")
		else:
			pass

func update_desktop_displays():
	# Called by ready() and _on_update_timer_timeout()
	for device in devices:
		var current_atlas_coords = device.atlas_coordinates
		var new_atlas_coords: Vector2i
		match [device.status, current_atlas_coords]:
			["online", Vector2i(0, 1)]:
				new_atlas_coords = Vector2i(0, 2)
				Logger.log("Status changed to 'online'", "status_change", device.name)
			["online", Vector2i(1, 1)]:
				new_atlas_coords = Vector2i(1, 2)
				Logger.log("Status changed to 'online'", "status_change", device.name)
			["offline", Vector2i(0, 2)]:
				new_atlas_coords = Vector2i(0, 1) 
				Logger.log("Status changed to 'offline'", "status_change", device.name)
			["offline", Vector2i(1, 2)]:
				new_atlas_coords = Vector2i(1, 1)
				Logger.log("Status changed to 'offline'", "status_change", device.name)
			_:
				new_atlas_coords = current_atlas_coords
				
		device.atlas_coordinates = new_atlas_coords
		set_cell(device.coordinates, 2, new_atlas_coords)

func get_status_from_atlas(atlas_coords: Vector2i) -> String:
	# Called by populate_devices()
	if atlas_coords in [Vector2i(0,2), Vector2i(1,2)]:
		return "online"
	elif atlas_coords in [Vector2i(0,1), Vector2i(1,1)]:
		return "offline"
	elif atlas_coords in [Vector2i(0,3), Vector2i(1,3)]:
		return "out-of-order"
	return "unknown"

func find_device_by_name(name_var: String) -> Device:
	# Called by populate_devices()
	for device in devices:
		if device.name == name_var:
			return device
	return null

func get_device_info(device: Device):
	# Unused
	return [device.name, device.status, device.user, device.coordinates, device.atlas_coordinates]

func get_devices():
	# Unused
	return devices
	
func _on_update_timer_timeout() -> void:
	populate_devices(load_json_file(SampleData))
	#populate_devices(data)
	update_desktop_displays()
	
func _on_http_request_node_result_ready() -> void:
	data = $HTTPRequestNode.prometheus_result

#
# -- FILE PARSING AND DATA CONVERSION BELOW
#

func load_json_file(filePath: String):
	# Called by ready() and _on_update_timer_timeout()
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("Error Reading File")
	else:
		print("File doesn't exist!")

func convert_keys_to_vector2i(dictionary: Dictionary) -> Dictionary:
	# Called by ready()
	var result = {}
	for key in dictionary.keys():
		var coord = string_to_vector2(key)
		var vector = Vector2i(coord)
		result[vector] = dictionary[key]
	return result
	
static func string_to_vector2(string := "") -> Vector2:
	# Called by convert_keys_to_vector2i()
	# I (kinn) totally copy+pasted this fn from the internet
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")

		return Vector2(int(array[0]), int(array[1]))

	return Vector2.ZERO
