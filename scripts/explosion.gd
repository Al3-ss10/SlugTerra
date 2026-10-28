extends Node2D
## Effetto/esplosione. Grafica e animazione sono nodi della scena (AnimationPlayer "boom").
## Se damage/knockback sono > 0 colpisce i nemici nel raggio all'istante.

@export var radius := 100.0
@export var damage := 0.0
@export var knockback := 0.0


func _ready() -> void:
	scale = Vector2.ONE * radius / 100.0
	if damage <= 0.0 and knockback <= 0.0:
		return
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead:
			continue
		var d: float = e.global_position.distance_to(global_position)
		if d < radius + e.radius:
			if damage > 0.0:
				e.take_damage(damage)
			if knockback > 0.0:
				e.global_position += (e.global_position - global_position).normalized() * knockback


func _on_animation_finished(_anim: StringName) -> void:
	queue_free()
