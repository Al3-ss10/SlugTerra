extends Node2D
## Scena principale: fasi, spawn dei nemici, esperienza e livelli.
## Tutte le scene (nemici, gemme, effetti...) sono assegnate dall'Inspector / main.tscn.

const PHASE_TIME := 60.0
const GOAL_TIME := 600.0 # 10 minuti = vittoria, poi puoi continuare all'infinito
const MAX_GEMS := 450
const PASSIVES := {
	"speed": ["Stivali Rapidi", "+12% velocità di movimento"],
	"rate": ["Cadenza Turbo", "+15% velocità di fuoco"],
	"dmg": ["Slug Potenziate", "+20% danno"],
	"magnet": ["Magnete di Gemme", "+40% raggio di raccolta"],
	"hp": ["Cuore di Slugterra", "+25 vita massima e cura 25"],
	"multi": ["Doppio Colpo", "+1 proiettile per Burpy"],
}

enum State { PLAY, LEVELUP, DEAD, WIN }

@export var ghoul_scene: PackedScene
@export var runner_scene: PackedScene
@export var brute_scene: PackedScene
@export var boss_scene: PackedScene
@export var heal_scene: PackedScene
@export var puff_scene: PackedScene
@export var phase_names: PackedStringArray

var state: State = State.PLAY
var time_alive := 0.0
var phase := 1
var goal_done := false
var kills := 0
var spawn_timer := 1.0
var msg := ""
var msg_t := 0.0
var xp := 0.0
var xp_next := 5.0
var level := 1
var pending := 0
var options: Array = []

@onready var world = $World
@onready var player = $Player
@onready var enemy_layer: Node2D = $Enemies
@onready var gem_layer: Node2D = $Gems
@onready var fx_layer: Node2D = $Effects
@onready var hud = $UI/HUD
@onready var menu = $UI/LevelUpMenu


func _ready() -> void:
	randomize()
	RenderingServer.set_default_clear_color(Color(0.03, 0.025, 0.07))
	world.target = player
	hud.main = self
	hud.player = player
	player.xp_gained.connect(_add_xp)
	player.died.connect(_on_player_died)
	menu.option_chosen.connect(_on_option_chosen)
	announce("FASE 1 — %s" % phase_name(1))


func phase_name(p: int) -> String:
	return phase_names[mini(p - 1, phase_names.size() - 1)]


func announce(text: String) -> void:
	msg = text
	msg_t = 3.0


func is_dead() -> bool:
	return state == State.DEAD


func is_won() -> bool:
	return state == State.WIN


func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func continue_game() -> void:
	state = State.PLAY
	get_tree().paused = false


func _physics_process(delta: float) -> void:
	if state != State.PLAY:
		return
	time_alive += delta
	if msg_t > 0.0:
		msg_t -= delta
	var new_phase := floori(time_alive / PHASE_TIME) + 1
	if new_phase != phase:
		phase = new_phase
		announce("FASE %d — %s" % [phase, phase_name(phase)])
		if phase % 4 == 0:
			_spawn_enemy(boss_scene)
			announce("FASE %d — Dr. Blakk manda un Ghoul Gigante!" % phase)
	if not goal_done and time_alive >= GOAL_TIME:
		goal_done = true
		state = State.WIN
		get_tree().paused = true
		return
	_spawn_logic(delta)


# ------------------------------------------------------------------ nemici
func _spawn_dist() -> float:
	return get_viewport_rect().size.length() * 0.5 + 60.0


func _spawn_logic(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	spawn_timer = maxf(0.07, 0.75 - phase * 0.06)
	var cap := mini(120 + phase * 30, 320)
	for _i in 1 + floori(phase / 2.0):
		if enemy_layer.get_child_count() >= cap:
			break
		var r := randf()
		if phase >= 3 and r < 0.08:
			_spawn_enemy(brute_scene)
		elif phase >= 2 and r < 0.35:
			_spawn_enemy(runner_scene)
		else:
			_spawn_enemy(ghoul_scene)


func _spawn_enemy(scene: PackedScene) -> void:
	var e = scene.instantiate()
	e.setup(phase)
	e.position = player.global_position + Vector2.from_angle(randf() * TAU) * _spawn_dist()
	e.died.connect(_on_enemy_died)
	enemy_layer.add_child.call_deferred(e)


func _on_enemy_died(e) -> void:
	kills += 1
	var puff = puff_scene.instantiate()
	puff.radius = e.radius * 1.6
	puff.position = e.global_position
	fx_layer.add_child.call_deferred(puff)
	if gem_layer.get_child_count() > MAX_GEMS:
		_add_xp(e.xp_value * e.drop_count)
		return
	for _k in e.drop_count:
		var spread: float = 0.0 if e.drop_count == 1 else randf_range(10.0, 60.0)
		_spawn_gem(e.drop_scene, e.global_position + Vector2.from_angle(randf() * TAU) * spread)
	if e.drops_heal or randf() < 0.015:
		_spawn_gem(heal_scene, e.global_position + Vector2(10, 0))


func _spawn_gem(scene: PackedScene, pos: Vector2) -> void:
	var g = scene.instantiate()
	g.position = pos
	gem_layer.add_child.call_deferred(g)


# ------------------------------------------------------------------ esperienza / livelli
func _add_xp(v: float) -> void:
	xp += v
	while xp >= xp_next:
		xp -= xp_next
		level += 1
		xp_next = floorf(xp_next * 1.18 + 4.0)
		pending += 1
	if pending > 0 and state == State.PLAY:
		_show_levelup()


func _roll_options() -> Array:
	var pool: Array = []
	for w in player.get_node("Weapons").get_children():
		if w.level < 5:
			var verb := "Sblocca " if w.level == 0 else "Potenzia "
			pool.append({
				"id": "weapon:%d" % w.get_index(),
				"label": "%s%s (Lv %d)" % [verb, w.display_name, w.level + 1],
				"desc": w.description,
			})
	for k in PASSIVES:
		pool.append({"id": "pas:" + k, "label": PASSIVES[k][0], "desc": PASSIVES[k][1]})
	pool.shuffle()
	return pool.slice(0, 3)


func _show_levelup() -> void:
	state = State.LEVELUP
	get_tree().paused = true
	options = _roll_options()
	menu.open(level - pending + 1, options)


func _on_option_chosen(i: int) -> void:
	if state != State.LEVELUP or i >= options.size():
		return
	var id: String = options[i]["id"]
	if id.begins_with("weapon:"):
		player.get_node("Weapons").get_child(int(id.substr(7))).upgrade()
	else:
		match id.substr(4):
			"speed": player.speed *= 1.12
			"rate": player.rate_mult *= 1.15
			"dmg": player.dmg_mult *= 1.2
			"magnet": player.set_magnet(player.magnet * 1.4)
			"hp":
				player.max_hp += 25.0
				player.hp = minf(player.hp + 25.0, player.max_hp)
			"multi": player.extra_shots += 1
	pending -= 1
	if pending > 0:
		_show_levelup()
	else:
		menu.close()
		state = State.PLAY
		get_tree().paused = false


func _on_player_died() -> void:
	state = State.DEAD
	get_tree().paused = true
