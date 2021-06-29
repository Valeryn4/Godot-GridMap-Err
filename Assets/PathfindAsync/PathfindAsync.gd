extends Node
class_name PathfindAsync

const TILE : = GridBitMap

enum TypeEvent {
	PATHFIND,
	SETRECT,
	GETPOINTS
}

signal path_changed()

export(Vector2) var world_size = Vector2.ONE * 16
export(Vector3) var cell_size = Vector3.ONE * 2
export(int) var layer = 0

var astar : AStar = null
var bitmap : BitMap = null
var world_queue : Array = []
var thread_worker : Thread = Thread.new()
var semaphore : Semaphore = Semaphore.new()
var mutex : Mutex = Mutex.new()
var exit_thread = false


func _ready() -> void:
	pass

func create(astar_ : AStar, bitmap_ : BitMap) -> void :
	astar = astar_
	bitmap = bitmap_
	
	set_rect(
		Rect2(Vector2.ONE, bitmap.get_size() - Vector2.ONE * 2), 
		0, 
		true
	)
	
	thread_worker.start(self, "_thread_worker")

func _pos_to_id(x : int, y : int) -> int :
	return y * world_size.x + x

func _posv_to_id(pos : Vector2) -> int :
	return _pos_to_id(pos.x as int, pos.y as int)

func request_get_path(from : Vector3, to : Vector3) -> PathfindRequestGetPath :
	var req = PathfindRequestGetPath.new()
	
	var from_grid : Vector3 = GridTransform.pos_to_grid_v3(from, cell_size)
	var to_grid : Vector3 = GridTransform.pos_to_grid_v3(to, cell_size)
	var from_id : int = _pos_to_id(from_grid.x as int, from_grid.z as int)
	var to_id : int = _pos_to_id(to_grid.x as int, to_grid.z as int)
	
	mutex.lock()
	world_queue.append({
		"type" : TypeEvent.PATHFIND,
		"from" : from_id,
		"to" : to_id,
		"req" : req
	})
	mutex.unlock()
	semaphore.post()
	return req

func set_rect(rect : Rect2, val : int, update_only : bool = false) -> void :
	mutex.lock()
	world_queue.append({
		"type" : TypeEvent.SETRECT,
		"rect" : rect,
		"val" : val,
		"upd" : update_only
	})
	mutex.unlock()
	semaphore.post()
	return

func request_get_points() -> PathfindRequestGetPoints:
	var req := PathfindRequestGetPoints.new()
	mutex.lock()
	world_queue.append({
		"type" : TypeEvent.GETPOINTS,
		"req" : req
	})
	mutex.unlock()
	semaphore.post()
	return req

func _update_astar_cell(mask : int, flag : int, id : int, grid_pos : Vector2) -> void :
	if mask & flag == flag :
		var pos_to : Vector2 = grid_pos + TILE.OFFSET_CELL[flag]
		var bit_to : bool = bitmap.get_bit(pos_to)
		var id_to : int = _posv_to_id(pos_to)
		
		
		if bit_to and not astar.has_point(id_to)  :
			var world_pos : Vector3 = Vector3(pos_to.x, layer, pos_to.y)
			var point : Vector3 = GridTransform.grid_to_pos_v3(world_pos, cell_size)
			astar.add_point(id_to, point)
		
		if astar.has_point(id_to) :
			if bit_to :
				if not astar.are_points_connected(id, id_to) :
					astar.connect_points(id, id_to)
			else :
				if astar.are_points_connected(id, id_to) :
					astar.disconnect_points(id, id_to)
	return

func _update_astar_cells(mask : int, grid_pos : Vector2, bit : bool) -> void :
	grid_pos += Vector2.ONE
	var id : int = _posv_to_id(grid_pos)
	if bit :#set point
		if not astar.has_point(id) :
			var world_pos : Vector3 = Vector3(grid_pos.x, layer, grid_pos.y)
			var point : Vector3 = GridTransform.grid_to_pos_v3(world_pos, cell_size)
			astar.add_point(id, point)
		
		_update_astar_cell(mask, TILE.TILE_TL, id, grid_pos)
		_update_astar_cell(mask, TILE.TILE_T,  id, grid_pos)
		_update_astar_cell(mask, TILE.TILE_TR, id, grid_pos)
		_update_astar_cell(mask, TILE.TILE_L,  id, grid_pos)
		_update_astar_cell(mask, TILE.TILE_R,  id, grid_pos)
		_update_astar_cell(mask, TILE.TILE_BL, id, grid_pos)
		_update_astar_cell(mask, TILE.TILE_B,  id, grid_pos)
		_update_astar_cell(mask, TILE.TILE_BR, id, grid_pos)
		
	else :#remove point
		if astar.has_point(id) :
			astar.remove_point(id)
	
	pass

func _get_mask_offset(mask : int, flag : int, grid_pos) -> int :
	grid_pos += TILE.OFFSET_CELL[flag]
	var bit : bool = bitmap.get_bit(grid_pos)
	if bit :
		return mask | flag
	return mask

func _get_mask(grid_pos : Vector2, bit : bool) -> int :
	if not bit :
		return 0
	var mask : int = 0
	mask = _get_mask_offset(mask, TILE.TILE_TL, grid_pos)
	mask = _get_mask_offset(mask, TILE.TILE_T,  grid_pos)
	mask = _get_mask_offset(mask, TILE.TILE_TR, grid_pos)
	mask = _get_mask_offset(mask, TILE.TILE_L,  grid_pos)
	mask = _get_mask_offset(mask, TILE.TILE_R,  grid_pos)
	mask = _get_mask_offset(mask, TILE.TILE_BL, grid_pos)
	mask = _get_mask_offset(mask, TILE.TILE_B,  grid_pos)
	mask = _get_mask_offset(mask, TILE.TILE_BR, grid_pos)
	return TILE.cut_bit_minimal(mask)

func _set_rect(rect : Rect2, val : int, update_only = false) -> void :
	if not update_only :
		bitmap.set_bit_rect(rect, val > 0)
	
	print("PathfindAsync set rect ", rect, " VAL: ", val)
	
	var update_rect : Rect2 = rect 
	update_rect.position -= Vector2.ONE
	update_rect.size += Vector2.ONE * 2
	
	
	print("PathfindAsync update rect ", update_rect)
	
	for x in update_rect.size.x :
		x = update_rect.position.x + x
		for y in update_rect.size.y :
			y = update_rect.position.y + y
			var pos_bit : Vector2 = Vector2(x, y)
			var bit : bool = bitmap.get_bit(pos_bit)
			var mask : int = _get_mask(pos_bit, bit)
			_update_astar_cells(mask, pos_bit, bit)
	return

func _thread_worker(_userdata) -> void :
	while true :
		semaphore.wait()
		
		mutex.lock()
		var should_exit = exit_thread # Protect with Mutex.
		var ev = world_queue.pop_front()
		mutex.unlock()
		if should_exit:
			break
		
		if ev != null :
			match ev.type :
				TypeEvent.PATHFIND :
					var req : PathfindRequestGetPath = ev.req
					req.call_deferred("set_answer", astar.get_point_path(ev.from, ev.to))
				TypeEvent.SETRECT :
					_set_rect(ev.rect, ev.val, ev.upd)
					self.call_deferred("_deferred_update")
				TypeEvent.GETPOINTS :
					var req : PathfindRequestGetPoints = ev.req
					var pool : PoolVector3Array = PoolVector3Array()
					for p in astar.get_points() :
						pool.append(astar.get_point_position(p))
					req.call_deferred("set_answer", pool)
		
		
		pass

func _exit_tree():
	if thread_worker.is_active() :
		# Set exit condition to true.
		mutex.lock()
		exit_thread = true # Protect with Mutex.
		mutex.unlock()
		# Unblock by posting.
		semaphore.post()
		# Wait until it exits.
		thread_worker.wait_to_finish()

func _deferred_update() -> void :
	emit_signal("path_changed")
