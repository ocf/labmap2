extends TileMapLayer

const Device = preload("res://device_class.gd")

const NamesDictionary = "res://name_dictionary.json"
var device_coordinates = {}

var devices = populate_desktops()

func _ready():
	device_coordinates = load_json_file(NamesDictionary)
	assign_names_to_desktops(devices)

func assign_names_to_desktops(devices: Array):
	# Called by ready()
	for device in devices:
		var coord = device.coordinates
#		if coord in NamesDictionary:
			# Assign the name from the dictionary
#			desktop.name = NamesDictionary.name_dictionary[coord]

func get_status_from_atlas(atlas_coords: Vector2i) -> String:
	# Called by populate_desktops(), get_all_tile_coordinates()
	if atlas_coords in [Vector2i(2,1), Vector2i(4,1)]:
		return "On"
	elif atlas_coords in [Vector2i(1,1), Vector2i(3,1)]:
		return "Off"
	return "Unknown"
	
func populate_desktops() -> Array:
	# Called by ready()
	var desktops = []
	var tile_coords = get_used_cells()
	
	for coord in tile_coords:
		var atlas_coords = get_cell_atlas_coords(Vector2i(coord))
		var status = get_status_from_atlas(atlas_coords)
		var desktop = Device.new("Default", coord, atlas_coords, status)
		desktops.append(desktop)
		
	return desktops

func get_all_tile_coordinates():
	# Called by populate_desktops()
	var tile_coordinates = get_used_cells()
	
	for coord in tile_coordinates:
		if get_cell_atlas_coords(Vector2i(coord)) in [Vector2i(4, 1), Vector2i(2, 1)]:
			print("Tile at: ", coord, ", Status: On")
		else:
			print("Tile at: ", coord, ", Status: Off")
		
	return tile_coordinates

func load_json_file(filePath: String):
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("Error Reading File")
	else:
		print("File doesn't exist!")
