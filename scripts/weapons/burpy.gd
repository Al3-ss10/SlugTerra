extends "res://scripts/weapons/weapon.gd"
## Burpy: raffica di proiettili sul nemico più vicino.


func fire() -> bool:
	var target = nearest_enemy(700.0)
	if target == null:
		return false
	var base: float = (target.global_position - player.global_position).angle()
	player.face = Vector2.from_angle(base)
	var n: int = 1 + player.extra_shots + floori((level - 1) / 2.0)
	var dmg: float = (10.0 + 4.0 * (level - 1)) * player.dmg_mult
	for j in n:
		var a := base + (j - (n - 1) * 0.5) * 0.16
		spawn_projectile(Vector2.from_angle(a), 520.0, dmg, 1)
	return true
