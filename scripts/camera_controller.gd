class_name CameraController

var camera: Camera3D
var orientation = Vector3(0, 0, -1)
var speed = 100
var sens = 0.002
var lastMouse = Vector2.ZERO

func _init(camera: Camera3D):
	self.camera = camera
			
func update(mouse: Vector2):
	if Input.is_action_pressed('fwd'):
		camera.position += orientation * speed
	if Input.is_action_pressed('bwd'):
		camera.position -= orientation * speed
	
	if Input.is_action_pressed('left'):
		camera.position -= orientation.cross(Vector3.UP).normalized() * speed
	if Input.is_action_pressed('right'):
		camera.position += orientation.cross(Vector3.UP).normalized() * speed
		
	if Input.is_action_pressed('up'):
		camera.position += Vector3.UP * speed
	if Input.is_action_pressed('down'):
		camera.position -= Vector3.UP * speed
	

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var d = mouse - lastMouse
		camera.rotation.y += -d.x * sens
		camera.rotation.x += -d.y * sens
		
		orientation = orientation.rotated(orientation.cross(Vector3.UP).normalized(), -d.y * sens)
		orientation = orientation.rotated(Vector3.UP, -d.x * sens)
		lastMouse = mouse
