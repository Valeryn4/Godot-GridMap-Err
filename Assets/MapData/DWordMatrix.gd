extends Reference

class_name DWordMatrix

export(PoolByteArray) var data : PoolByteArray = []
export(Vector2) var size : Vector2 = Vector2.ZERO

const NIL = -1
const MAX = (255 << 8) | 255 #[bytebyte] - 16 bit data
const MIN = 0

func _init(_size : Vector2 = Vector2(128, 128), _data : PoolByteArray = []) -> void:
	size = _size
	if not _data.empty() and _data.size() == size.x * size.y * 2:
		data = _data
	else :
		data.resize(size.x * size.y * 2)
	return

func get_cell(x : int, y : int) -> int :
	var idx : int = get_cell_idx(x, y)
	if idx < 0 or idx >= data.size() :
		return NIL
	var idx2 : int = get_cell_right_idx(x, y)
	var left := data[idx]
	var right := data[idx2]
	return (left << 8 | right)

func is_bit_enabled(mask : int, index : int) -> bool:
	return mask & (1 << index) != 0

func enable_bit(mask : int, index : int) -> int:
	return mask | (1 << index)

func disable_bit(mask, index) -> int:
	return mask & ~(1 << index)


func set_cell(x : int, y : int, val : int) -> void :
	var idx = get_cell_idx(x, y)
	data[idx] = val
	return

func get_cell_idx(x : int, y : int) -> int :
	var idx = size.x * 2 * y + (x * 2)
	return idx

func get_cell_right_idx(x : int, y : int) -> int :
	var idx = size.x * 2 * y + (x * 2 + 1)
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

func set_rect(rect : Rect2, y : int, val : int) -> void :
	for x in rect.size.x :
		for y in rect.size.y :
			set_cell(x, y, val)
	return

func get_rect_success(rect : Rect2) -> bool :
	if rect.position.x < 0 or rect.position.y < 0 :
		return false
	
	if get_cell(rect.position.x + rect.size.x as int, rect.position.y + rect.size.y as int) == NIL :
		return false
	
	return true
