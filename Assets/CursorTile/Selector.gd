extends Spatial

export(Color) var color = Color.blue setget set_color
export(float, 0, 1) var opacity = 0.8
func set_color(val : Color) -> void :
	color = val
	_change_color()
	

func _ready() -> void:
	_change_color()
	pass

func _change_color() -> void :
	var mat : SpatialMaterial = $MeshInstance.material_override
	mat.albedo_color = color
	mat.albedo_color.a = opacity
	
