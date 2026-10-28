extends Area2D
## Singolo tornado orbitante (figlio dell'arma Tormato). Il danno viene dall'arma.


func _physics_process(delta: float) -> void:
	$Swirl.rotation += delta * 9.0
	var dmg: float = get_parent().damage()
	for a in get_overlapping_areas():
		if a.is_in_group("enemies") and not a.dead and a.tcd <= 0.0:
			a.take_damage(dmg)
			a.tcd = 0.4
			a.global_position += (a.global_position - global_position).normalized() * 14.0
