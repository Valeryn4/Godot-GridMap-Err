extends Spatial


const MASK_PLANER = 524288

onready var plane_cast = $MeshInstance


export(Vector3) var cell_size = Vector3.ONE * 2
export(float) var layer = 0


var last_cursor_position_world : Vector3 = Vector3.INF
var last_cursor_position_grid : Vector3 = Vector3.INF
var camera : Camera = null

func _ready():
	_update_planer_selector(_get_camera())
	pass

func _get_camera() -> Camera :
	if camera == null :
		camera = get_viewport().get_camera()
	
	return camera

func _update_planer_selector(cam : Camera) -> void :
	if cam :
		var camera_parent = cam.get_parent()
		if camera_parent is Spatial :
			var g_transform : Transform = camera_parent.global_transform
			plane_cast.global_transform = Transform(Basis(), Vector3(g_transform.origin.x, layer * cell_size.y, g_transform.origin.z))


func _cast_position(screen_point : Vector2) -> Dictionary :
	if not _get_camera() :
		return {}
	
	var from = camera.project_ray_origin(screen_point) #create a ray origin at the mouse position
	var to = from + camera.project_ray_normal(screen_point) * 2000 #Extend the ray by raylength
	
	_update_planer_selector(camera)
	var space_state = get_world().direct_space_state #Gets AABB/Physics information
	var result = space_state.intersect_ray(from, to, [], MASK_PLANER) #Get ray intersection object, exclude colliders except layer 1 - this is our object
	return result


func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion :
		var result = _cast_position(event.position)
		if result :
			var world_position = result.position
			var grid_position = GridTransform.pos_to_grid_v3(world_position, cell_size)
			var world_on_grid_position = GridTransform.grid_to_pos_v3(grid_position, cell_size)
			var ev = InputEventGridMotion.new()
			ev.position_grid = grid_position
			ev.position_world = world_position
			ev.position_world_center = world_on_grid_position
			Input.parse_input_event(ev)
	elif event is InputEventMouseButton :
		var result = _cast_position(event.position)
		if result :
			var world_position = result.position
			var grid_position = GridTransform.pos_to_grid_v3(world_position, cell_size)
			var world_on_grid_position = GridTransform.grid_to_pos_v3(grid_position, cell_size)
			var ev = InputEventGridButton.new()
			ev.position_grid = grid_position
			ev.position_world = world_position
			ev.position_world_center = world_on_grid_position
			ev.button_idx = event.button_index
			ev.pressed = event.is_pressed()
			Input.parse_input_event(ev)
			
