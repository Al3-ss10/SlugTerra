extends Node2D
## Decorazione generica (cristallo, fungo, roccia): variazione casuale di scala, specchio e colore.


func randomize_look(rng: RandomNumberGenerator, color: Color) -> void:
	var s := rng.randf_range(0.7, 1.4)
	scale = Vector2(s * (1.0 if rng.randf() < 0.5 else -1.0), s)
	if has_node("Glow"):
		modulate = color
	else:
		rotation = rng.randf_range(-0.4, 0.4)
