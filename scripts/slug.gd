extends Node2D
var target
var tipo
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target =Vector2(0, 0)
	if tipo == "fuoco":
		print("ole")
	else: 
		print("odio i primini")
		
	sprite.play(tipo)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target != global_position:
		global_position=global_position.move_toward(target, 300 *delta)
	if target==global_position:
		print("arrivato")
		queue_free()
