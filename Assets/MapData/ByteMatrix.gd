extends Reference
class_name ByteMatrix

export(PoolByteArray) var data : PoolByteArray = []
export(Vector2) var size : Vector2 = Vector2.ZERO

const NIL = -1

func _init(_size : Vector2 = Vector2(128, 128), _data : PoolByteArray = []) -> void:
	size = _size
	if not _data.empty() and _data.size() == size.x * size.y:
		data = _data
	else :
		data.resize(int(size.x * size.y))
		fill(0)
	return

func fill(val : int) -> void :
	for i in data.size() :
		data[i] = val

func get_cell(x : int, y : int) -> int :
	var idx = get_cell_idx(x, y)
	assert(idx < data.size() and idx >= 0)
	return data[idx]

func set_cell(x : int, y : int, val : int) -> void :
	var idx = get_cell_idx(x, y)
	assert(idx < data.size() and idx >= 0)
	data[idx] = val
	return

func get_cell_idx(x : int, y : int) -> int :
	var idx = size.x * y + x
	return idx

func get_cellv_idx(pos : Vector2) -> int :
	return get_cell_idx(pos.x as int, pos.y as int)

func get_cellv(pos : Vector2) -> int :
	return get_cell(pos.x as int, pos.y as int)

func set_cellv(pos : Vector2, val : int) -> void :
	set_cell(pos.x as int, pos.y as int, val)

func compress() -> PoolByteArray :
	return data.compress(File.COMPRESSION_GZIP)

func decompress(_data : PoolByteArray) -> void :
	data = _data.decompress(1024, File.COMPRESSION_GZIP)
	return

func set_rect(rect : Rect2, val : int) -> void :
	for x in rect.size.x :
		for y in rect.size.y :
			set_cell(x + rect.position.x, y + rect.position.y, val)
	return

func get_rect_success(rect : Rect2) -> bool :
	if rect.position.x < 0 or rect.position.y < 0 :
		return false
	
	if get_cell(int(rect.position.x + rect.size.x), int(rect.position.y + rect.size.y)) == NIL :
		return false
	
	return true
