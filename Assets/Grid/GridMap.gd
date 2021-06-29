extends GridMap


"""

GRID BUILDER

"""

signal update_builders(rect_build, tile_type)
# warning-ignore:unused_signal
signal failed_builder(rect)
# warning-ignore:unused_signal
signal success_builder(rect)

const TILE = GridBitMap
const NIL_CELL = -1
const DEFAULT_ORT = 0
const EMPTY_TILE_TYPE = 0
const UPDATE_RADIUS = 2


export(Vector2) var grid_size = Vector2(16, 16)
export(int) var layer : int = 0
export(String, FILE) var grid_bitmap_path = ""
var grid_bitmap = null



var grid_data : GridData = null

func _ready() -> void:
	
	pass


func init_grid() -> void :
	
	grid_data = GridData.new(grid_size)
	
	grid_bitmap = load(grid_bitmap_path)
	var mesh_path = grid_bitmap.get_meshlib_path()
	var mesh_lib = load(mesh_path)
	self.mesh_library = mesh_lib
	

func get_grid_data() -> GridData :
	return grid_data
	

func _get_cell_mask(mask : int, flag : int, grid_pos : Vector2) -> int :
	var pos = grid_pos + GridBitMap.OFFSET_CELL[flag]
	var cell = get_grid_data().get_tile_map().get_cellv(pos)
	if cell != NIL_CELL and cell != EMPTY_TILE_TYPE :
		return mask | flag
	return mask

func _get_cell_mask_full(mask_tile : int, grid_pos : Vector2) -> int :
	mask_tile = _get_cell_mask(mask_tile, TILE.TILE_TL, grid_pos)
	mask_tile = _get_cell_mask(mask_tile, TILE.TILE_T, grid_pos)
	mask_tile = _get_cell_mask(mask_tile, TILE.TILE_TR, grid_pos)
	mask_tile = _get_cell_mask(mask_tile, TILE.TILE_L, grid_pos)
	mask_tile = _get_cell_mask(mask_tile, TILE.TILE_R, grid_pos)
	mask_tile = _get_cell_mask(mask_tile, TILE.TILE_BL, grid_pos)
	mask_tile = _get_cell_mask(mask_tile, TILE.TILE_B, grid_pos)
	mask_tile = _get_cell_mask(mask_tile, TILE.TILE_BR, grid_pos)
	return mask_tile


func _update_zone(rect : Rect2, _tile_type : int = 0) -> void :
	
	var bitmap : GridBitMap = grid_bitmap
	for x in rect.size.x :
		for y in rect.size.y :
			var grid_pos : Vector2 = Vector2(x + rect.position.x, y + rect.position.y)
			var byte = grid_data.tile_map.get_cellv(grid_pos)
			var mask_tile = TILE.TILE_NONE
			var item : int = NIL_CELL
			var orientaton : int = DEFAULT_ORT
			
			if byte != EMPTY_TILE_TYPE and byte != ByteMatrix.NIL :
				mask_tile = _get_cell_mask_full(mask_tile, grid_pos)
				match bitmap.mode :
					GridBitMap.Mode.MODE_3x3_MINIMAL :
						mask_tile = GridBitMap.cut_bit_minimal(mask_tile)
				
				var current_layer : String = GridConsts.ROOM_ID_TO_NAME[byte]
				
				var meshes_data := bitmap.get_meshes(mask_tile, current_layer)
				if meshes_data.empty() :
					item = -1
					orientaton = 0
				else :
					var mesh_data = meshes_data[randi() % meshes_data.size()]
					item = mesh_data.id
					orientaton = mesh_data.rot
				
			self.set_cell_item(int(grid_pos.x), 0, int(grid_pos.y), item, orientaton)
			
			
	return

### build room function. rect - position and size room. tile_type - data value room
func _build_room(rect: Rect2, tile_type : int ) -> void :
	
	if rect.size.x <= 0 or rect.size.y <= 0 :
		return
	
	var build_rect : Rect2 = Rect2(Vector2.ONE, grid_size - Vector2.ONE * 2).clip(rect)
	get_grid_data().set_rect(build_rect, tile_type)
	
	
	var update_rect : Rect2 = build_rect
	update_rect.position -= Vector2.ONE * (UPDATE_RADIUS * 0.5)
	update_rect.size += Vector2.ONE * UPDATE_RADIUS
	
	update_rect = Rect2(Vector2.ONE, grid_size - Vector2.ONE * 2).clip(update_rect)
	_update_zone(update_rect, tile_type)
	
	print("BUILD RECT: ", build_rect)
	print("UPDATE RECT: ", update_rect)
	emit_signal("update_builders", build_rect, tile_type)



func build_room(rect : Rect2, tile_type : int) -> void :
	_build_room(rect, tile_type)
