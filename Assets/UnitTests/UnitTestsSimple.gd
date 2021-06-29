tool
extends EditorScript

func _run() -> void:
	_unit_test("_unit_test_GirdMatrixCell")

func _unit_test(func_name : String) -> void :
	print("START UNIT ", func_name)
	var res = self.call(func_name)
	print("- RESULT: ", "OK" if res else "FAILED!")

func _assert_equal_print(val, equal, text) -> Array :
	var res = (val == equal)
	return [res, text]

func _assert_not_equal_print(val, equal, text) -> Array :
	var res = (val != equal)
	return [res, text]

func _print_assert(val : Array) -> bool :
	if not val[0] :
		print("--ERROR: ", val[1])
	return val[0]

func _unit_test_GirdMatrixCell() -> bool :
	
	var matrix : = ByteGrid.new(Vector3(3, 3, 3))
	var i = 0
	for x in 3 :
		for y in 3 :
			for z in 3 :
				matrix.set_cell(x, y, z, i)
				i += 1
	
	
	i = 0
	for x in 3 :
		for y in 3 :
			for z in 3 :
				var text : String = "ZERO INDEX %s EQUAL %s POS(%s, %s, %s)" % [i, i, x, y, z]
				var cell = matrix.get_cell(x,y,z)
				if not _print_assert(_assert_equal_print(cell, i, text)) :
					return false
				i += 1
	
	var text : String = "ZERO INDEX %s NOT EQUAL %s POS(%s, %s, %s)" % [0, 1, 0, 0, 0]
	var cell = matrix.get_cell(0, 0, 0)
	if not _print_assert(_assert_not_equal_print(cell,  1, text)) :
		return false
	
	return true 

