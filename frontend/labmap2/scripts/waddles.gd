'''
This script pertains to the behavior of the Waddles sprites as they appear on screen.
It gives the Waddles path files (.tres) to follow to their devices, as well as
taking those same paths back to the door when they leave. It also as functions
ensuring the Waddles are facing the correct direction when they walk by checking
the difference between their current position and the position they were in in the
moment prior.
'''

extends Node2D

@onready var path_2d = $Path2D
@onready var path_follow = $Path2D/PathFollow2D  # Reference to PathFollow2D within Path2D
@onready var waddles_sprite = $Path2D/PathFollow2D/Waddles

var speed: float = 1.0
var target_destination = ""
var travel_duration = 3.0
var progress_ratio = 0.0
var path_length = 0.0
var last_position: Vector2 = Vector2.ZERO
var is_returning = false

func _ready():
	pass

func _process(delta: float):
	progress_ratio += speed * delta
	progress_ratio = clamp(progress_ratio, 0.0, 1.0)
	path_follow.progress_ratio = progress_ratio
	
	update_animation_direction()
	
	if is_returning and progress_ratio <= 0.05:
		waddles_sprite.modulate.a -= delta
		if waddles_sprite.modulate.a == 0:
			queue_free()

func set_target_desktop(desktop_name: String):
	# Called by spawn_waddles_if_logged_in() in floor_map.gd
	target_destination = desktop_name
	var path_resource = load("res://paths/to_%s.tres" % desktop_name)
	if path_resource:
		path_2d.curve = path_resource
	else:
		Logger.log("No path to device %s" % desktop_name, "Warning", desktop_name)
		return
	# Reset the PathFollow2D position and start movement
	path_follow.h_offset = 0
	path_follow.v_offset = 0
	path_follow.progress_ratio = 0
	path_length = path_2d.curve.get_baked_length()
	speed = speed / (travel_duration * (path_length / 400))

func walk_back_to_door():
	# Called by spawn_waddles_if_logged_in() in floor_map.gd
	is_returning = true
	path_follow.progress_ratio = 1.0
	speed = -abs(speed)

func update_animation_direction():
	# Called by process()
	var current_position = path_follow.position
	var dx = current_position.x - last_position.x
	var dy = current_position.y - last_position.y
	
	if dx > 0 and dy > 0:
		# Moving south-east
		waddles_sprite.frame = 0
		waddles_sprite.flip_h = false
	elif dx > 0 and dy < 0:
		# Moving north-east
		waddles_sprite.frame = 1
		waddles_sprite.flip_h = true
	elif dx < 0 and dy > 0:
		# Moving south-west
		waddles_sprite.frame = 0
		waddles_sprite.flip_h = true
	elif dx < 0 and dy < 0:
		# Moving north-west
		waddles_sprite.frame = 1
		waddles_sprite.flip_h = false
	else:
		# No movement, keep the current animation
		pass
	
	last_position = current_position
