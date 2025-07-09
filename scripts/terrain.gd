extends Node3D
class_name Terrain

var chunkInstance = preload('res://scenes/chunk.tscn')
var noise = FastNoiseLite.new()
var chunks: Dictionary = {}
var chunk_size = 200
var max_lod = 4

func _ready():
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.2
	noise.seed = 123456
	
func create_chunk(world_pos: Vector3, lod: int, left_lod: int, right_lod: int, top_lod: int, bottom_lod: int) -> MeshInstance3D:
	var chunk = chunkInstance.instantiate()
	chunk.init(world_pos, noise, lod, chunk_size, left_lod, right_lod, top_lod, bottom_lod)
	return chunk
