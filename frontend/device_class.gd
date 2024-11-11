extends Object

class_name Device

var name: String
var coordinates: Vector2i
var atlas_coordinates: Vector2i
var status: String
var logged_in: String
var user: String

# Constructor for the TileDesktop object
func _init(name_var: String, coordinates_var: Vector2i, atlas_coordinates_var: Vector2i, status_var: String, logged_in_var: String, user_var: String):
	self.name = name_var
	self.coordinates = coordinates_var
	self.atlas_coordinates = atlas_coordinates_var
	self.status = status_var
	self.logged_in = logged_in_var
	self.user = user_var
