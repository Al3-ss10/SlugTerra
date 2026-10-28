extends Node2D
## Protagonista: si muove con WASD. Aspetto e camera sono nodi in player.tscn.

@export var speed := 220.0


func _physics_process(delta: float) -> void:
	var v := Vector2(
		int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)),
		int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W)))
	position += v.normalized() * speed * delta
