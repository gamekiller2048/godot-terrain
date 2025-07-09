extends MeshInstance3D
class_name Chunk

var pos: Vector3
var noise: FastNoiseLite
var lod: int
var size: float
var left_lod: int
var right_lod: int
var top_lod: int
var bottom_lod: int

@onready var divisions: int = floor(16 / pow(2, lod))
var amplitude: float = 500
var generated = false

func init(pos: Vector3, noise: FastNoiseLite, lod: int, size: float, left_lod: int, right_lod: int, top_lod: int, bottom_lod: int):
	self.pos = pos
	position = pos
	
	self.noise = noise
	self.lod = lod
	self.size = size
	self.left_lod = left_lod
	self.right_lod = right_lod
	self.top_lod = top_lod
	self.bottom_lod = bottom_lod
	self.noise.seed
	
func height_at(x, z):
	var cx = x * size / divisions
	var cz = z * size / divisions
	return noise.get_noise_2d((pos.x + cx) / size, (pos.z + cz) / size) * amplitude

func generate_mesh():
	var vertices = []
	vertices.resize(Mesh.ARRAY_MAX)
		
	var positions = PackedVector3Array()
	var indices = PackedInt32Array()
	var normals = PackedVector3Array()
	var colors = PackedColorArray()
	
	var edges = divisions + 1
	for x in range(edges):
		for z in range(edges):
			var h = height_at(x, z)
			positions.push_back(Vector3(x * size / divisions, h, z * size / divisions))
			
			if lod == 1:
				colors.push_back(Color(255, 0, 0))
			elif lod == 2:
				colors.push_back(Color(0, 255, 0))
			elif lod == 3:
				colors.push_back(Color(0, 0, 255))
			elif lod == 4:
				colors.push_back(Color(0, 255, 255))
			
			var p = Vector3(x, height_at(x, z), z)
			var v1 = p - Vector3(x + 1, height_at(x + 1, z), z)
			var v2 = p - Vector3(x, height_at(x, z + 1), z + 1)
			normals.append(v2.cross(v1).normalized())
							
	for x in range(divisions):
		for z in range(divisions):
			var i = x * edges + z
			indices.append_array([i, i + edges, i + 1])
			indices.append_array(([i + edges + 1, i + 1, i + edges]))
	
	if lod < left_lod:
		for z in range(0, edges - 1, 2):
			positions[z + 1] = Vector3(positions[z + 1].x, (positions[z].y + positions[z + 2].y) / 2, positions[z + 1].z)	

	if lod < right_lod:
		for z in range(0, edges - 1, 2):
			var i = z + divisions * edges
			positions[i + 1] = Vector3(positions[i + 1].x, (positions[i].y + positions[i + 2].y) / 2, positions[i + 1].z)

	if lod < top_lod:		
		for x in range(0, edges - 1, 2):
			positions[(x + 1) * edges] = Vector3(positions[(x + 1) * edges].x, (positions[x * edges].y + positions[(x + 2) * edges].y) / 2, positions[(x + 1) * edges].z)

	if lod < bottom_lod:		
		for x in range(0, edges - 1, 2):
			positions[(x + 1) * edges + edges - 1] = Vector3(positions[(x + 1) * edges + edges - 1].x, (positions[x * edges + edges - 1].y + positions[(x + 2) * edges + edges - 1].y) / 2, positions[(x + 1) * edges + edges - 1].z)


	vertices[Mesh.ARRAY_VERTEX] = positions
	vertices[Mesh.ARRAY_INDEX] = indices
	vertices[Mesh.ARRAY_NORMAL] = normals
	vertices[Mesh.ARRAY_COLOR] = colors
	
	
	var update_mesh = func():
		var m = ArrayMesh.new()
		m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, vertices)
		mesh = m
	
	update_mesh.call_deferred()
	generated = true
	
func _ready():
	WorkerThreadPool.add_task(generate_mesh)
