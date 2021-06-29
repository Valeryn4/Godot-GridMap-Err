extends Reference
class_name GridData


var size_map : Vector2 = Vector2.ZERO
var tile_map : ByteMatrix = null
var collision_map : BitMap = null


func _init(size : Vector2) -> void :
	tile_map = ByteMatrix.new(size)
	collision_map = BitMap.new()
	collision_map.create(size)
	size_map = size

func get_tile_map() -> ByteMatrix :
	return tile_map

func get_collision_map() -> BitMap :
	return collision_map

func get_size_map() -> Vector2 :
	return size_map

func set_rect(rect : Rect2, type : int) -> void :
	tile_map.set_rect(rect, type)
	collision_map.set_bit_rect(rect, type > 0)



func pos_to_id(pos : Vector2) -> int :
	return int(pos.y * size_map.x + pos.x)

func posv3_to_id(pos : Vector3) -> int :
	return int(pos.z * size_map.x + pos.x)
