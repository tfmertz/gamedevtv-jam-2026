extends Camera2D

# how far it shakes
var shake_strength := 0.0
# how fast shake fades
var shake_decay := 5.0

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = Vector2.ZERO

func shake(strength: float) -> void:
	shake_strength = strength
