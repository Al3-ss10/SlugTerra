extends Control
## HUD: tutti gli elementi sono nodi in hud.tscn; qui si aggiornano solo valori e testi.
## main e player vengono assegnati da main.gd.

var main
var player

@onready var xp_bar: ProgressBar = $XpBar
@onready var hp_bar: ProgressBar = $HpBar
@onready var hp_label: Label = $HpBar/HpLabel
@onready var time_label: Label = $TimeLabel
@onready var phase_label: Label = $PhaseLabel
@onready var stats_label: Label = $StatsLabel
@onready var message_label: Label = $MessageLabel
@onready var slots: Array = $Slots.get_children()
@onready var game_over: Control = $GameOver
@onready var win: Control = $Win
@onready var summary: Label = $GameOver/Center/Box/Summary


func _process(_delta: float) -> void:
	if main == null or player == null:
		return
	xp_bar.max_value = main.xp_next
	xp_bar.value = main.xp
	hp_bar.max_value = player.max_hp
	hp_bar.value = player.hp
	hp_label.text = "HP %d / %d" % [ceili(player.hp), int(player.max_hp)]
	var secs := int(main.time_alive)
	var clock := "%02d:%02d" % [floori(secs / 60.0), secs % 60]
	time_label.text = clock
	phase_label.text = "Fase %d — %s" % [main.phase, main.phase_name(main.phase)]
	stats_label.text = "Liv. %d   Ghoul sconfitti: %d" % [main.level, main.kills]
	message_label.text = main.msg
	message_label.visible = main.msg_t > 0.0
	message_label.modulate.a = clampf(main.msg_t, 0.0, 1.0)
	var weapons: Array = player.get_node("Weapons").get_children()
	for i in slots.size():
		slots[i].visible = weapons[i].level > 0
		slots[i].get_node("Label").text = "Lv%d" % weapons[i].level
	game_over.visible = main.is_dead()
	win.visible = main.is_won()
	if main.is_dead():
		summary.text = "Sei sopravvissuto %s — Livello %d — %d ghoul sconfitti" % [clock, main.level, main.kills]


func _input(event: InputEvent) -> void:
	if main == null:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if main.is_dead() and (event.keycode == KEY_R or event.keycode == KEY_ENTER):
			main.restart()
		elif main.is_won() and (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE):
			main.continue_game()
