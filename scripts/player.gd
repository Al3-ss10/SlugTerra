extends Area2D
## Il giocatore. Aspetto, collisioni, camera e armi sono nodi in player.tscn.

signal xp_gained(value: float)
signal died

@export var hit_ring_scene: PackedScene

var max_hp := 100.0
var hp := 100.0
var speed := 220.0
var dmg_mult := 1.0
var rate_mult := 1.0
var magnet := 90.0
var extra_shots := 0
var iframes := 0.0
var face := Vector2.RIGHT
var t := 0.0
var _dead := false

@onready var visual: Node2D = $Visual
@onready var blaster: Node2D = $Visual/Blaster
@onready var magnet_ring: Sprite2D = $MagnetRing
@onready var magnet_shape: CollisionShape2D = $Magnet/Shape


func _ready() -> void:
	set_magnet(magnet)


func set_magnet(r: float) -> void:
	magnet = r
	magnet_shape.shape.radius = r
	magnet_ring.scale = Vector2.ONE * r / 57.6


func collect(kind: String, value: float) -> void:
	if kind == "heal":
		hp = minf(hp + value, max_hp)
	else:
		xp_gained.emit(value)


func hurt(amount: float) -> void:
	if iframes > 0.0 or _dead:
		return
	hp -= amount
	iframes = 0.6
	var ring = hit_ring_scene.instantiate()
	ring.position = global_position
	get_tree().get_first_node_in_group("fx_layer").add_child.call_deferred(ring)
	if hp <= 0.0:
		hp = 0.0
		_dead = true
		died.emit()


func _on_magnet_area_entered(area: Area2D) -> void:
	if area.is_in_group("gems"):
		area.attract()


func _physics_process(delta: float) -> void:
	t += delta
	iframes = maxf(iframes - delta, 0.0)
	var v := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): v.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): v.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): v.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): v.y += 1.0
	if v != Vector2.ZERO:
		v = v.normalized()
		global_position += v * speed * delta
		if get_tree().get_nodes_in_group("enemies").is_empty():
			face = v
	for a in get_overlapping_areas():
		if a.is_in_group("enemies"):
			hurt(a.damage)
			break
	blaster.rotation = face.angle()
	visual.visible = not (iframes > 0.0 and int(t * 20.0) % 2 == 0)
