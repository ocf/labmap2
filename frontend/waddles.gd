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
	target_destination = desktop_name
	# Load the path resource based on the desktop name
	var path_resource = load("res://paths/to_%s.tres" % desktop_name)
	if path_resource:
		path_2d.curve = path_resource  # Set the path on the local Path2D node
	# Reset the PathFollow2D position and start movement
	path_follow.h_offset = -580
	path_follow.v_offset = 10
	path_follow.progress_ratio = 0  # Starts at the beginning of the path
	path_length = path_2d.curve.get_baked_length()
	speed = 1.0 / (travel_duration * (path_length / 400))

func walk_back_to_door():
	is_returning = true
	path_follow.progress_ratio = 1.0
	speed = -abs(speed)

func update_animation_direction():
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
