extends "res://scripts/weapons/weapon.gd"
## Infurnus: palla di fuoco che esplode al contatto (il danno è calcolato dall'esplosione).


func fire() -> bool:
	var target = random_enemy(560.0)
	if target == null:
		return false
	var dir: Vector2 = (target.global_position - player.global_position).normalized()
	spawn_projectile(dir, 360.0, 0.0, 1)
	if level >= 4:
		spawn_projectile(dir.rotated(0.35), 360.0, 0.0, 1)
	return true
