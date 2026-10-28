extends Control
## Menu di scelta del potenziamento. Funziona anche con il gioco in pausa
## (il CanvasLayer UI ha process_mode "Always"). I pulsanti sono collegati nella scena.

signal option_chosen(index: int)

@onready var title: Label = $Center/Box/Title
@onready var buttons: Array = [$Center/Box/Option1, $Center/Box/Option2, $Center/Box/Option3]


func open(level_number: int, options: Array) -> void:
	title.text = "LIVELLO %d!   Scegli un potenziamento (tasti 1-2-3)" % level_number
	for i in 3:
		buttons[i].text = "%d)  %s\n%s" % [i + 1, options[i]["label"], options[i]["desc"]]
	visible = true
	buttons[0].grab_focus()


func close() -> void:
	visible = false


func _on_option_pressed(i: int) -> void:
	option_chosen.emit(i)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var idx := -1
		if event.keycode == KEY_1: idx = 0
		elif event.keycode == KEY_2: idx = 1
		elif event.keycode == KEY_3: idx = 2
		if idx >= 0:
			get_viewport().set_input_as_handled()
			option_chosen.emit(idx)
