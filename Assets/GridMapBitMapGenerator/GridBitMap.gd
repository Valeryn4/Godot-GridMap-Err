extends Resource
class_name GridBitMap

const TILE_NONE = 0b_0000_0000
const TILE_TL =   0b_0000_0001
const TILE_T =    0b_0000_0010
const TILE_TR =   0b_0000_0100
const TILE_L =    0b_0000_1000
const TILE_R =    0b_0001_0000
const TILE_BL =   0b_0010_0000
const TILE_B =    0b_0100_0000
const TILE_BR =   0b_1000_0000
const TILE_TBRL = TILE_T | TILE_B | TILE_R | TILE_L
const TILE_FULL = TILE_TBRL | TILE_TL | TILE_TR | TILE_BL | TILE_BR


enum Mode {
	MODE_2x2,
	MODE_3x3_MINIMAL,
	MODE_3x3
}

const BITS = {
	Mode.MODE_2x2 : 4,
	Mode.MODE_3x3_MINIMAL : 8,
	Mode.MODE_3x3 : 8
}

const SIZE_BITS = {
	Mode.MODE_2x2 : pow(2, 4),
	Mode.MODE_3x3_MINIMAL : pow(2, 8),
	Mode.MODE_3x3 : pow(2, 8)
}

const OFFSET_CELL = {
	TILE_TL : Vector2.UP + Vector2.LEFT,
	TILE_T  : Vector2.UP,
	TILE_TR : Vector2.UP + Vector2.RIGHT,
	TILE_L  : Vector2.LEFT,
	TILE_R  : Vector2.RIGHT,
	TILE_BL : Vector2.DOWN + Vector2.LEFT,
	TILE_B  : Vector2.DOWN,
	TILE_BR : Vector2.DOWN + Vector2.RIGHT
}

const ID_MESH = "id"
const ROT_MESH = "rot"

const EXAMPLE_MESH_DATA = {
	"layer_name" : {
		0b_0000_0000 : {
			"grid_name" : [
				#variant 1
				{
					ID_MESH : 0,
					ROT_MESH : 0
				},
				#variant 2
				{
					ID_MESH : 1,
					ROT_MESH : 0
				}
			],
		}
	}
}


export(Mode) var mode = Mode.MODE_3x3_MINIMAL
export(String) var meshlib_path : String = "" 
export(Dictionary) var mesh_data : Dictionary = {} # {mask : {"layer_name" : [{id_wall : 0, rot_wall : 0, id_floor : 0, rot_floor : 0]}}

func create(mode_ : int, path : String) -> void :
	mode = mode_
	meshlib_path = path

#get path Mesh library resource
func get_meshlib_path() -> String :
	return meshlib_path

func get_layers() -> Array :
	var layers : Array = mesh_data.keys()
	return layers

func get_meshes_from_layer(layer_name : String) -> Dictionary :
	var layers : Dictionary = mesh_data.get(layer_name, {})
	return layers

func get_meshes(mask : int, layer : String) -> Dictionary :
	var meshes : Dictionary = get_meshes_from_layer(layer).get(mask, {})
	return meshes


func set_meshlib(path : String) -> void :
	meshlib_path = path


func set_mesh(mask : int, id : int, rot : int, layer : String, grid_name : String, variant : int) -> void :
	
	var data := {
		ID_MESH : id,
		ROT_MESH : rot
	}
	
	if not mesh_data.has(layer) :
		mesh_data[layer] = {}
	
	if not mesh_data[layer].has(mask) :
		mesh_data[layer][mask] = {}
	
	if not mesh_data[layer][mask].has(grid_name) :
		mesh_data[layer][mask][grid_name] = []
	
	if mesh_data[layer][mask][grid_name].size() > variant :
		mesh_data[layer][mask][grid_name][variant] = data
	else :
		mesh_data[layer][mask][grid_name].append(data)


static func is_enabled_bit(mask : int, index : int) -> bool:
	return mask & (1 << index) != 0

static func set_bit(mask : int, index : int) -> int:
	return mask | (1 << index)

static func remove_bit(mask : int, index : int) -> int :
	return mask & ~(1 << index)

static func has_flag(mask, flag) -> bool :
	return (mask & flag == flag)

static func _has_flag_and_cut(mask : int, mask_target : int, mask_cond : int) -> int :
	if has_flag(mask, mask_target | mask_cond): 
		return mask
	return mask & ~(mask_target)


static func cut_bit_minimal(mask : int) -> int :
	mask = _has_flag_and_cut(mask, TILE_TL, TILE_T | TILE_L)
	mask = _has_flag_and_cut(mask, TILE_TR, TILE_T | TILE_R)
	mask = _has_flag_and_cut(mask, TILE_BL, TILE_B | TILE_L)
	mask = _has_flag_and_cut(mask, TILE_BR, TILE_B | TILE_R)
	return mask

static func _skip_check_bit(mask : int, mask_target : int, has_mask : int) -> bool :
	return (
		(mask & mask_target == mask_target) and 
		(mask & has_mask != has_mask)
	) 

static func skip_bit_minimal(mask : int) -> bool :
		return (
			_skip_check_bit(mask, TILE_TL, TILE_T | TILE_L) or
			_skip_check_bit(mask, TILE_TR, TILE_T | TILE_R) or
			_skip_check_bit(mask, TILE_BL, TILE_B | TILE_L) or
			_skip_check_bit(mask, TILE_BR, TILE_B | TILE_R)
		)
	
