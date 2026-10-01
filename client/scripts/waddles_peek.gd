# waddles will peek, look around, and go back to hiding behind the wall

extends PathFollow2D

@export var move_speed := 50.0
@export var flip_speed := 0.3
@export var pause_duration := 2.0
@export var peek_interval := 1800.0 # 30 min

enum State {
	HIDDEN,
	MOVING_UP,
	LOOKING,
	MOVING_DOWN
}
var state = State.HIDDEN # start out as hidden

@onready var timer = $PeekInterval
@onready var waddles = $Waddles

func _ready():
	# looping is controlled by this script, dont auto loop
	self.loop = false

	# start as hidden
	waddles.visible = false

	# configure the timer
	timer.wait_time = peek_interval
	timer.one_shot = false
	timer.autostart = true
	timer.start()
	timer.timeout.connect(self._on_timer_timeout)

# on timeout, start the peeking sequence if waddles is hiding
func _on_timer_timeout():
	if state == State.HIDDEN:
		state = State.MOVING_UP
		print("waddles: haii")

# move up or down a bit on each frame if the sequence is in progress
# speed is configurable with move_speed
func _process(delta):
	# length of the path wadddles follows to peek
	var path_len = get_parent().curve.get_baked_length()

	match state:
		State.MOVING_UP:
			waddles.visible = true
			progress += move_speed * delta # move up a bit

			# when waddles reaches the end of the path and is currently peeking
			# above the wall, look around
			if progress >= path_len:
				progress = path_len
				state = State.LOOKING
				look_around()
		State.MOVING_DOWN:
			progress -= move_speed * delta # move down a bit

			# when waddles goes back to the start of the path, hide again
			if progress <= 0:
				progress = 0
				state = State.HIDDEN
				waddles.visible = false
				print("waddles: byee")

func look_around():
	print("waddles: 👀")
	var tween = create_tween()

	# pause, look left, pause, look right, pause, move down
	tween.tween_callback(func(): pass).set_delay(pause_duration)
	tween.tween_property(waddles, "scale:x", - waddles.scale.x, flip_speed) # flip
	tween.tween_callback(func(): pass).set_delay(pause_duration)
	tween.tween_property(waddles, "scale:x", + waddles.scale.x, flip_speed) # flip back
	tween.tween_callback(func(): state = State.MOVING_DOWN).set_delay(pause_duration)
