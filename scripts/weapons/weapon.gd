extends Node2D
## Classe base delle armi. Le armi sono nodi già presenti in player.tscn:
## level 0 = non sbloccata (nascosta e inattiva). Le sottoclassi implementano fire().

@export var display_name := ""
@export var description := ""
@export var base_cooldown := 1.0
@export var level := 0
@export var projectile_scene: PackedScene
@export var explosion_scene: PackedScene

var player
var _cd := 0.3


func _ready() -> void:
	player = get_parent().get_parent() # Weapons -> Player
	_apply_level()


func upgrade() -> void:
	level += 1
	_apply_level()


func _apply_level() -> void:
	visible = level > 0
	set_physics_process(level > 0)


func _physics_process(delta: float) -> void:
	_cd -= delta
	if _cd > 0.0:
		return
	_cd = (base_cooldown / player.rate_mult) if fire() else 0.12


## Ritorna true se ha sparato (altrimenti riprova a breve).
func fire() -> bool:
	return false


func living_enemies() -> Array:
	var out: Array = []
	for e in get_tree().get_nodes_in_group("enemies"):
		if not e.dead:
			out.append(e)
	return out


func nearest_enemy(maxd: float):
	var best = null
	var best_d := maxd
	for e in living_enemies():
		var d: float = e.global_position.distance_to(player.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best


func random_enemy(maxd: float):
	var cands: Array = []
	for e in living_enemies():
		if e.global_position.distance_to(player.global_position) < maxd:
			cands.append(e)
	if cands.is_empty():
		return null
	return cands[randi() % cands.size()]


func spawn_projectile(dir: Vector2, speed: float, dmg: float, pierce: int) -> void:
	var p = projectile_scene.instantiate()
	p.velocity = dir * speed
	p.damage = dmg
	p.pierce = pierce
	p.level = level
	p.dmg_mult = player.dmg_mult
	p.position = player.global_position + dir * 18.0
	get_tree().get_first_node_in_group("projectile_layer").add_child.call_deferred(p)
