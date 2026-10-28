extends "res://scripts/weapons/weapon.gd"
## Frostcrawler: proiettile di ghiaccio che rallenta e trapassa.


func fire() -> bool:
	var target = nearest_enemy(700.0)
	if target == null:
		return false
	var dir: Vector2 = (target.global_position - player.global_position).normalized()
	var dmg: float = (8.0 + 3.0 * (level - 1)) * player.dmg_mult
	spawn_projectile(dir, 460.0, dmg, 1 + floori(level / 2.0))
	return true
