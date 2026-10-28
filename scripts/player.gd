extends Node2D
## Protagonista: si muove con WASD. Aspetto e camera sono nodi in player.tscn.

@export var speed := 220.0
var sceglitipo=1
var tipo
func _physics_process(delta: float) -> void:
	var v := Vector2(
		int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)),
		int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W)))
	position += v.normalized() * speed * delta
	if Input.is_action_just_pressed("Spara"):
		
		if sceglitipo%2==0:
			tipo="fuoco"
		else:
			tipo="ghiaccio"
		sceglitipo+=1
		spara(tipo)
	
func spara(type):
	var Scena = preload("res://scenes/Slug.tscn")
	var istanza = Scena.instantiate()
	istanza.position = Vector2(100, 200)
	istanza.tipo=type
	add_child(istanza)
	
