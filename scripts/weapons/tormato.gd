extends "res://scripts/weapons/weapon.gd"
## Tormato: i 5 tornado (T1..T5) sono già nodi della scena; qui si attivano e si dispongono.
## Il nodo arma ruota su se stesso e i tornado orbitano con lui.

@onready var tornados: Array = get_children()


func damage() -> float:
	return (5.0 + 3.0 * level) * player.dmg_mult


func _apply_level() -> void:
	super()
	var n := 1 + floori(level / 2.0) if level > 0 else 0
	for i in tornados.size():
		var on: bool = i < n
		tornados[i].visible = on
		tornados[i].process_mode = Node.PROCESS_MODE_INHERIT if on else Node.PROCESS_MODE_DISABLED
		if on:
			tornados[i].position = Vector2.from_angle(TAU * i / n) * (95.0 + 8.0 * level)


func _physics_process(delta: float) -> void:
	rotation += delta * 2.6
