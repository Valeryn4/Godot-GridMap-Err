extends InputEventGrid
class_name InputEventGridButton

const ACTION_NAME_DEFAULT = "GRID_PRESSED_CURSOR"

export(int) var button_idx

func _init() -> void :
	self.action = ACTION_NAME_DEFAULT


