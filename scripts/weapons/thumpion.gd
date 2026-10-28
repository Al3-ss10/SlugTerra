extends "res://scripts/weapons/weapon.gd"
## Thumpion: onda d'urto attorno al player (danno + knockback), scena shockwave.tscn.


func fire() -> bool:
	var radius := 110.0 + 18.0 * level
	var any := false
	for e in living_enemies():
		if e.global_position.distance_to(player.global_position) < radius + e.radius:
			any = true
			break
	if not any:
		return false
	var ex = explosion_scene.instantiate()
	ex.radius = radius
	ex.damage = (12.0 + 5.0 * (level - 1)) * player.dmg_mult
	ex.position = player.global_position
	get_tree().get_first_node_in_group("fx_layer").add_child.call_deferred(ex)
	return true
