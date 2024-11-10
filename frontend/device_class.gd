extends Object

class_name Device

var name: String
var coordinates: Vector2i
var atlas_coordinates: Vector2i
var status: String
var logged_in: String
var user: String

# Constructor for the TileDesktop object
func _init(name: String, coordinates: Vector2i, atlas_coordinates: Vector2i, status: String, logged_in: String, user: String):
	self.name = name
	self.coordinates = coordinates
	self.atlas_coordinates = atlas_coordinates
	self.status = status
	self.logged_in = logged_in
	self.user = user
