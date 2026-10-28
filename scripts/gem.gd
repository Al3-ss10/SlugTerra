extends Area2D
## Gemma/moneta: kind "xp" (esperienza) oppure "heal" (cuore che cura).

@export var kind := "xp"
@export var value := 1.0

var pulled := false
var player: Node2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func attract() -> void:
	pulled = true


func _physics_process(delta: float) -> void:
	if player == null:
		return
	var to_p: Vector2 = player.global_position - global_position
	var d := to_p.length()
	if d < player.magnet:
		pulled = true
	if pulled and d > 0.1:
		global_position += to_p / d * 420.0 * delta
	if d < 16.0:
		player.collect(kind, value)
		queue_free()
	elif d > 2500.0:
		queue_free()
