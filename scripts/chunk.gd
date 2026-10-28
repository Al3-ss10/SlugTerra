extends Node2D
## Un pezzo di mappa 512x512: sparge decorazioni (scene) in modo deterministico dal seed.

const CHUNK := 512

@export var crystal_scene: PackedScene
@export var mushroom_scene: PackedScene
@export var rock_scene: PackedScene
@export var palette: PackedColorArray

var _seed := 0


func setup(c: Vector2i, world_seed: int) -> void:
	position = Vector2(c.x * CHUNK, c.y * CHUNK)
	_seed = hash(Vector3i(c.x, c.y, world_seed))


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed
	_scatter(rng, rock_scene, rng.randi_range(1, 4))
	_scatter(rng, mushroom_scene, rng.randi_range(2, 5))
	_scatter(rng, crystal_scene, rng.randi_range(2, 4))


func _scatter(rng: RandomNumberGenerator, scene: PackedScene, count: int) -> void:
	for i in count:
		var d = scene.instantiate()
		d.position = Vector2(rng.randf() * CHUNK, rng.randf() * CHUNK)
		d.randomize_look(rng, palette[rng.randi() % palette.size()])
		add_child(d)
