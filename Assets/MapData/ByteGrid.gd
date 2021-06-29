extends Reference

class_name ByteGrid

export(PoolByteArray) var data : PoolByteArray = []
export(Vector3) var size : Vector3 = Vector3.ZERO

const NIL = -1

func _init(_size : Vector3 = Vector3(128, 10, 128), _data : PoolByteArray = []) -> void:
	size = _size
	if not _data.empty() and _data.size() == size.x * size.y * size.z:
		data = _data
	else :
		data.resize(size.x * size.y * size.z)
	return

func get_cell(x : int, y : int, z : int) -> int :
	var idx = get_cell_idx(x, y, z)
	if idx < 0 or idx >= data.size() :
		return NIL
	return data[idx]

func set_cell(x : int, y : int, z : int, val : int) -> void :
	var idx = get_cell_idx(x, y, z)
	data[idx] = val
	return

func get_cell_idx(x : int, y : int, z : int) -> int :
	var idx = (x + (size.y * (y  + size.z * z))) as int
	return idx

func get_cellv_idx(pos : Vector3) -> int :
	return get_cell_idx(pos.x as int, pos.y as int, pos.z as int)

func get_cellv(pos : Vector3) -> int :
	return get_cell(pos.x as int, pos.y as int, pos.z as int)

func set_cellv(pos : Vector3, val : int) -> void :
	set_cell(pos.x as int, pos.y as int, pos.z as int, val)

func compress() -> PoolByteArray :
	return data.compress(File.COMPRESSION_GZIP)

func decompress(_data : PoolByteArray) -> void :
	data = _data.decompress(1024, File.COMPRESSION_GZIP)
	return

func set_rect(rect : Rect2, y : int, val : int) -> void :
	for x in rect.size.x :
		for z in rect.size.y :
			set_cell(x, y, z, val)
	return

func get_rect_success(rect : Rect2, y : int) -> bool :
	if rect.position.x < 0 or rect.position.y < 0 :
		return false
	
	if get_cell(rect.position.x + rect.size.x as int, y, rect.position.y + rect.size.y as int) == NIL :
		return false
	
	return true
