extends Area2D
## Nemico generico. Le statistiche e l'aspetto di ghoul/runner/brute/boss
## sono definiti nelle rispettive scene (scenes/enemies/*.tscn).

signal died(enemy)

@export var max_hp := 18.0
@export var speed := 65.0
@export var radius := 14.0
@export var damage := 8.0
@export var xp_value := 1.0
@export var drop_scene: PackedScene
@export var drop_count := 1
@export var drops_heal := false

var hp := 18.0
var slow := 0.0
var hit := 0.0
var tcd := 0.0 # cooldown danno tornado
var dead := false
var wob := 0.0
var t := 0.0
var base_color := Color.WHITE
var player: Node2D

@onready var visual: Node2D = $Visual
@onready var body: Sprite2D = $Visual/Body
@onready var slow_ring: Sprite2D = $Visual/SlowRing
@onready var hp_fill = get_node_or_null("HpBar/Fill")


func setup(phase: int) -> void:
	max_hp *= 1.0 + (phase - 1) * 0.25
	speed *= 1.0 + minf(phase * 0.04, 0.4)


func _ready() -> void:
	hp = max_hp
	wob = randf() * TAU
	base_color = body.modulate
	player = get_tree().get_first_node_in_group("player")


func take_damage(amount: float) -> void:
	if dead:
		return
	hp -= amount
	hit = 0.1
	if hp <= 0.0:
		dead = true
		died.emit(self)
		queue_free()
	elif hp_fill:
		hp_fill.scale.x = clampf(hp / max_hp, 0.0, 1.0)


func apply_slow(duration: float) -> void:
	slow = duration


func _physics_process(delta: float) -> void:
	if dead or player == null:
		return
	t += delta
	slow = maxf(slow - delta, 0.0)
	hit = maxf(hit - delta, 0.0)
	tcd -= delta
	var to_p: Vector2 = player.global_position - global_position
	var d := to_p.length()
	if d > 0.1:
		global_position += to_p / d * speed * (0.5 if slow > 0.0 else 1.0) * delta
	var edge := get_viewport_rect().size.length() * 0.5 + 60.0
	if d > edge + 500.0:
		global_position = player.global_position + Vector2.from_angle(randf() * TAU) * edge
	visual.position.y = sin(t * 8.0 + wob) * 2.0
	body.modulate = Color.WHITE if hit > 0.0 else base_color
	slow_ring.visible = slow > 0.0
