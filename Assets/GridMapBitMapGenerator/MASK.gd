tool
extends GridMap

const FALSE_BIT = 0
const TRUE_BIT = 1
const BIT_MAP_SIZE = {
	GridBitMap.Mode.MODE_2x2 : 2,
	GridBitMap.Mode.MODE_3x3 : 3,
	GridBitMap.Mode.MODE_3x3_MINIMAL : 3
}

export(GridBitMap.Mode) var mode = GridBitMap.Mode.MODE_3x3_MINIMAL
export(int, 8, 1024) var width = 16
export(bool) var gen = false setget set_gen
func set_gen(val : bool) -> void :
	gen = false 
	if val :
		_generate()

export(bool) var write_resource = false setget set_write_resource
func set_write_resource(val : bool) -> void :
	write_resource = false
	if val :
		_write_res()

export(MeshLibrary) var mesh_lib = null
export(Resource) var result_data = null

func _set_cell_3x3_from_flag(x : int, y : int, mask : int, flag : int) -> void :
	var bit = GridBitMap.has_flag(mask, flag)
	self.set_cell_item(x, 0, y, TRUE_BIT if bit else FALSE_BIT)

func _set_fill_cells_3x3_from_flag(bit_x : int, bit_y : int, mask, center_fill : bool = true) -> void :
	self.set_cell_item(bit_x + 1, 0, bit_y + 1, TRUE_BIT if center_fill else FALSE_BIT)
	_set_cell_3x3_from_flag(bit_x,     bit_y,     mask, GridBitMap.TILE_TL)
	_set_cell_3x3_from_flag(bit_x + 1, bit_y,     mask, GridBitMap.TILE_T)
	_set_cell_3x3_from_flag(bit_x + 2, bit_y,     mask, GridBitMap.TILE_TR)
	_set_cell_3x3_from_flag(bit_x,     bit_y + 1, mask, GridBitMap.TILE_L)
	_set_cell_3x3_from_flag(bit_x + 2, bit_y + 1, mask, GridBitMap.TILE_R)
	_set_cell_3x3_from_flag(bit_x,     bit_y + 2, mask, GridBitMap.TILE_BL)
	_set_cell_3x3_from_flag(bit_x + 1, bit_y + 2, mask, GridBitMap.TILE_B)
	_set_cell_3x3_from_flag(bit_x + 2, bit_y + 2, mask, GridBitMap.TILE_BR)

func _generate() -> void :
	clear()
	var bitmap_size = BIT_MAP_SIZE[mode]
	
	var block_x : int = 0
	var block_y : int = 0
	
	var max_value_bitmask = GridBitMap.SIZE_BITS[mode]
	for mask in max_value_bitmask :
		match mode :
			GridBitMap.Mode.MODE_3x3_MINIMAL :
				if not GridBitMap.skip_bit_minimal(mask) :
					var bit_x : int = block_x * bitmap_size
					var bit_y : int = block_y * bitmap_size
					_set_fill_cells_3x3_from_flag(bit_x, bit_y, mask)
					block_x += 1
					if block_x >= width:
						block_x = 0
						block_y += 1
	
	
	_set_fill_cells_3x3_from_flag(block_x * bitmap_size, block_y * bitmap_size, 0, false)

	
	var count_collumn : int = width
	var count_row : int = block_y + 1
	
	$Horizontal.multimesh.mesh.size.z = count_row * bitmap_size * 2.0
	$Vertical.multimesh.mesh.size.x = count_collumn * bitmap_size * 2.0
	
	$Horizontal.multimesh.instance_count = count_collumn + 1
	$Vertical.multimesh.instance_count = count_row + 1
	for x in count_collumn + 1 : 
		$Horizontal.multimesh.set_instance_transform(x, Transform(Basis(), Vector3(x * bitmap_size * 2.0, 1.0, $Horizontal.multimesh.mesh.size.z * 0.5)))
		for y in count_row + 1 :
			$Vertical.multimesh.set_instance_transform(y, Transform(Basis(), Vector3($Vertical.multimesh.mesh.size.x * 0.5, 1.0, y * bitmap_size * 2.0)))
		
	

func _write_res() -> void :
	var layers = $Layers
	result_data = GridBitMap.new()
	result_data.create(mode, mesh_lib.resource_path)
	for tile_grid in layers.get_children() :
		var layer_name = tile_grid.name
		for grid_node in tile_grid.get_children() :
			var grid_name = grid_node.name
		
			var bitmap_size = BIT_MAP_SIZE[mode]
			
			
			var block_x : int = 0
			var block_y : int = 0
			
			var max_value_bitmask = GridBitMap.SIZE_BITS[mode]
			for mask in max_value_bitmask :
				match mode :
					GridBitMap.Mode.MODE_3x3_MINIMAL :
						if not GridBitMap.skip_bit_minimal(mask) :
							var bit_x : int = block_x * bitmap_size + 1
							var bit_y : int = block_y * bitmap_size + 1
							var variant : int = 0
							var id : int = -1
							while true :
								var orientation = 0
								id = grid_node.get_cell_item(bit_x, variant, bit_y)
								if id == -1 and variant > 0 :
									break
								orientation = grid_node.get_cell_item_orientation(bit_x, variant, bit_y)
								result_data.set_mesh(mask, id, orientation, layer_name, grid_name, variant)
								block_x += 1
								if block_x >= width:
									block_x = 0
									block_y += 1
								
								variant += 1
		

