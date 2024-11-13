extends AnimatedSprite2D

var spawned_in = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spawned_in and modulate.a <= 1.0:
		modulate.a += delta
	else:
		spawned_in = false
