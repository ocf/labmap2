'''
This script manages the Waddles sprite itself, and not it's behavior.
The only thing this script manages is the Waddles asset itself as well
as make the sprite fade in/out when it approaches the door.
'''

extends AnimatedSprite2D

var spawned_in = true

func _ready() -> void:
	modulate.a = 0

func _process(delta: float) -> void:
	if spawned_in and modulate.a <= 1.0:
		modulate.a += delta
	else:
		spawned_in = false
