extends Area2D
## Proiettile-slug. Aspetto e tipo (normale / fuoco / ghiaccio) sono definiti
## nelle scene in scenes/projectiles/.

@export var explosion_scene: PackedScene # se impostata, esplode al contatto (fuoco)
@export var slows := false # rallenta i nemici colpiti (ghiaccio)

var velocity := Vector2.ZERO
var damage := 10.0
var pierce := 1
var level := 1
var dmg_mult := 1.0
var life := 1.6
var hit_ids: Array = []
var _done := false


func _ready() -> void:
	if has_node("Flame"):
		$Flame.rotation = velocity.angle()


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	life -= delta
	if life <= 0.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if _done or not area.is_in_group("enemies") or area.dead:
		return
	var id := area.get_instance_id()
	if hit_ids.has(id):
		return
	hit_ids.append(id)
	if explosion_scene:
		var ex = explosion_scene.instantiate()
		ex.radius = 55.0 + 10.0 * level
		ex.damage = (10.0 + 5.0 * level) * dmg_mult
		ex.position = global_position
		get_tree().get_first_node_in_group("fx_layer").add_child.call_deferred(ex)
		_done = true
		queue_free()
		return
	area.take_damage(damage)
	if slows:
		area.apply_slow(2.0)
	pierce -= 1
	if pierce <= 0:
		_done = true
		queue_free()
