class_name ChunkManager

var camera: Camera3D
var terrain: Terrain

func _init(terrain: Terrain, camera: Camera3D):
	self.terrain = terrain
	self.camera = camera

func calc_lod(world_pos: Vector3) -> int:
	return max(min(floor((camera.position - world_pos).length() / terrain.chunk_size / 2), terrain.max_lod), 1)
		
func update():
	var new_chunks = {}

	for n in range(-20, 20):
		for m in range(-20, 20):
			var world_pos = (floor(Vector3(camera.position.x, 0, camera.position.z) / terrain.chunk_size) + Vector3(n, 0, m)) * terrain.chunk_size
			var lod = calc_lod(world_pos)
			var left_lod = calc_lod(world_pos - Vector3(terrain.chunk_size, 0, 0))
			var right_lod = calc_lod(world_pos + Vector3(terrain.chunk_size, 0, 0))

			var top_lod = calc_lod(world_pos - Vector3(0, 0, terrain.chunk_size))
			var bottom_lod = calc_lod(world_pos + Vector3(0, 0, terrain.chunk_size))

			if world_pos in terrain.chunks and lod == terrain.chunks[world_pos].lod and left_lod == terrain.chunks[world_pos].left_lod and right_lod == terrain.chunks[world_pos].right_lod and top_lod == terrain.chunks[world_pos].top_lod and bottom_lod == terrain.chunks[world_pos].bottom_lod:
				new_chunks[world_pos] = terrain.chunks[world_pos]
				terrain.chunks.erase(world_pos)
			else:
				new_chunks[world_pos] = terrain.create_chunk(world_pos, lod, left_lod, right_lod, top_lod, bottom_lod)
				terrain.add_child(new_chunks[world_pos])
	
	for chunk in terrain.chunks.values():
		terrain.remove_child(chunk)

	terrain.chunks = new_chunks
	
	for chunk in terrain.chunks.values():
		var bottom_left = chunk.position
		var bottom_right = chunk.position + Vector3(0, 0, terrain.chunk_size)
		var top_right = chunk.position + Vector3(terrain.chunk_size, 0, terrain.chunk_size)
		var top_left = chunk.position + Vector3(terrain.chunk_size, 0, 0)
				
		if chunk.generated and (camera.is_position_in_frustum(bottom_left) or camera.is_position_in_frustum(top_right) or camera.is_position_in_frustum(bottom_right) or camera.is_position_in_frustum(top_left)):
			chunk.show()
		else:
			chunk.hide()
