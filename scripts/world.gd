extends Node2D
## Mappa infinita. Il pavimento è un ParallaxLayer con texture di rumore ripetuta (nella scena);
## qui si creano solo i Chunk di decorazioni attorno al giocatore.

const CHUNK := 512

@export var chunk_scene: PackedScene

var target: Node2D
var world_seed := 0
var chunks := {}


func _ready() -> void:
	world_seed = randi()


func _process(_delta: float) -> void:
	if target == null:
		return
	var half := get_viewport_rect().size * 0.5 + Vector2(160, 160)
	var a := Vector2i(((target.global_position - half) / CHUNK).floor())
	var b := Vector2i(((target.global_position + half) / CHUNK).floor())
	for x in range(a.x, b.x + 1):
		for y in range(a.y, b.y + 1):
			var c := Vector2i(x, y)
			if not chunks.has(c):
				var ch = chunk_scene.instantiate()
				ch.setup(c, world_seed)
				add_child(ch)
				chunks[c] = ch
	for c in chunks.keys():
		if c.x < a.x - 1 or c.x > b.x + 1 or c.y < a.y - 1 or c.y > b.y + 1:
			chunks[c].queue_free()
			chunks.erase(c)
