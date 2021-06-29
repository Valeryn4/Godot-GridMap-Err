extends Spatial

onready var cursor := $CursorTile
onready var camera := $CameraMover
onready var grid := $GridMapGenerator
onready var cursor_object := $CursorPoint
onready var cursor_detector := $Cursor
onready var pathfind_async := $PathfindAsync
onready var enemyes_pull := $Enemyes
onready var enemy_ai := $EnemyAI

export(Vector2) var world_size : Vector2 = Vector2(16, 16)
export(Vector3) var cell_size : Vector3 = Vector3.ONE * 2
export(int) var layer := 0
export(Resource) var grid_bitmap_res = null
export(int, 0, 255) var current_tile_type := 1

var mode : int = 0
var is_active_game_zone : bool = false

func _ready():
	_init_grid()
	_init_camera()
	_init_cursor()
	_init_cursor_point()
	_init_cursor_detector()
	_init_pathfind_async()

func _init_cursor_point() -> void :
	cursor_object.cell_size = cell_size
	cursor_object.size_world = world_size

func _init_cursor_detector() -> void :
	cursor_detector.cell_size = cell_size
	cursor_detector.layer = layer
	
func _init_pathfind_async() -> void :
	pathfind_async.cell_size = cell_size
	pathfind_async.world_size = world_size
	pathfind_async.layer = layer
	pathfind_async.create(AStar.new(), grid.get_grid_data().get_collision_map())

func _init_grid() -> void :
	grid.grid_size = world_size
	grid.cell_size = cell_size
	grid.layer = layer
	grid.grid_bitmap = grid_bitmap_res
	grid.init_grid()

func _init_camera() -> void :
	camera.translation = Vector3(world_size.x * 0.5 * cell_size.x, layer * cell_size.y, world_size.y * 0.5 * cell_size.z)

func _init_cursor() -> void :
	cursor.cell_size = cell_size
	cursor.current_layer = layer
	cursor.size_world = world_size

func _on_CursorTile_select_rect(rect : Rect2) -> void:
	rect.position -= Vector2.ONE
	match mode :
		GridConsts.BUILD_MODE_ROOM_DEFAULT :
			grid.build_room(rect, 1)
		GridConsts.BUILD_MODE_REMOVE :
			grid.build_room(rect, 0)
	pass # Replace with function body.


func _update_update_mode() -> void :
	if is_active_game_zone :
		camera.active_build = true
		match mode :
			GridConsts.BUILD_MODE_ROOM_DEFAULT :
				cursor.active_build = true
				cursor.selector_color = Color.blue
				cursor.select_zone_color = Color.green
				cursor_object.active_build = false
			GridConsts.BUILD_MODE_REMOVE :
				cursor.active_build = true
				cursor.selector_color = Color.orangered
				cursor.select_zone_color = Color.red
				cursor_object.active_build = false
			GridConsts.BUILD_MODE_SETUP_OBJECT :
				cursor.active_build = false
				cursor_object.active_build = true
			GridConsts.BUILD_MODE_SET_PATH :
				cursor.active_build = false
				cursor_object.active_build = true
	else :
		camera.active_build = false
		cursor.active_build = false
		cursor_object.active_build = false

func _on_UIBuilder_change_build_mode(mode_ : int) -> void:
	mode = mode_
	if not is_active_game_zone :
		return
	_update_update_mode()


func _on_UIBuilder_entered_game_zone() -> void:
	is_active_game_zone = true
	_update_update_mode()
	print("FOCUS GAME ZONE ON")


func _on_UIBuilder_exit_game_zone() -> void:
	is_active_game_zone = false
	_update_update_mode()
	print("FOCUS GAME ZONE OFF")



func _on_CursorPoint_click_global(pos : Vector3) -> void:
	match mode :
		GridConsts.BUILD_MODE_SETUP_OBJECT :
			var enemy = preload("res://Assets/Enemy/Enemy.tscn").instance()
			enemy.translation = pos
			enemy.translation.y = layer * cell_size.y + 1.5
			enemyes_pull.add_child(enemy)
			enemy_ai.add_enemy(enemy)
		GridConsts.BUILD_MODE_SET_PATH :
			_move_object_to(pos)
	
	pass # Replace with function body.

func _create_mesh_debug(color : Color, size : float) -> MeshInstance :
	var mesh_ins = MeshInstance.new()
	var mesh = CubeMesh.new()
	mesh.size = Vector3.ONE * size
	mesh_ins.mesh = mesh
	var mat = SpatialMaterial.new()
	mat.albedo_color = color
	mesh_ins.material_override = mat
	return mesh_ins

func _move_object_to(to : Vector3) -> void :
	
	for enemy in enemyes_pull.get_children() :
		var work := WorkMoveTo.new(enemy, to, pathfind_async)
		enemy_ai.push_work(work)

func _on_GridMap_update_builders(rect_build : Rect2, tile_type : int) -> void:
	print("SET RECT TO PATHFIND ", rect_build)
	pathfind_async.set_rect(rect_build, tile_type)



func _on_PathfindAsync_path_changed() -> void:
	var req : PathfindRequestGetPoints = pathfind_async.request_get_points()
	yield(req,"completed")
	
	for node in $DebugPathfindCells.get_children() :
		node.queue_free()
	
	var mesh_ins = _create_mesh_debug(Color.blue, 0.7)
	for pos in req.answer() :
		var m = mesh_ins.duplicate()
		m.translation = pos
		m.translation.y = layer
		$DebugPathfindCells.add_child(m)
	pass # Replace with function body.


func _on_UIBuilder_clear_game() -> void:
	grid.build_room(Rect2(Vector2.ZERO, world_size), 0)
	for enemy in enemyes_pull.get_children() :
		enemy_ai.remove_enemy(enemy)
		enemy.queue_free()
