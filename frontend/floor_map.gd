extends Node2D

var devices
var penguin_sprite: AnimatedSprite2D
var door_position = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	check_for_logged_in_user(devices)
	
func check_for_logged_in_user(devices_var):
	for device in devices_var:
		if device.status == "online" and device.user != "none":
			print("Logged in user found at: ", device.name, ", the user is: ", device.user)
			spawn_penguin_at_device(device)
			
func spawn_penguin_at_device(device_var):
	if penguin_sprite == null:
		penguin_sprite = AnimatedSprite2D.new()
		add_child(penguin_sprite)
		
	penguin_sprite.position = door_position
	penguin_sprite.play("walk")
	
	var path = Path2D.new()
	path.add_point(door_position)
	path.add_point(device_var.coordinates)
	
	var tween = Tween.new()
	add_child(tween)
	tween.tween_property(penguin_sprite, "position", device_var.coordinates, 5.0)
