extends Node3D

@onready var terrain = $Terrain
@onready var camera = $Camera3D
@onready var chunk_manager = ChunkManager.new(terrain, camera)
@onready var camera_controller = CameraController.new(camera)

#func _ready():
	##RenderingServer.set_debug_generate_wireframes(true)
	##get_viewport().set_debug_draw(4)		

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			camera_controller.lastMouse = get_viewport().get_mouse_position()
			
func _process(delta):
	chunk_manager.update()
	camera_controller.update(get_viewport().get_mouse_position())
	
