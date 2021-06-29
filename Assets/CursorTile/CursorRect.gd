extends Spatial

signal finished(rect)

onready var multi_mesh_instance = $MultiMesh
onready var animation = $MultiMesh/AnimationPlayer

export(Rect2) var grid_rect : Rect2 setget set_grid_rect
func set_grid_rect(val : Rect2) -> void :
	grid_rect = val
	_update_draw(grid_rect)
	return

export(Vector3) var cell_size : Vector3 = Vector3.ONE * 2.0
export(Color) var color = Color.green setget set_color
export(float, 0, 1) var opacity = 0.8
func set_color(val : Color) -> void :
	_change_color()
	color = val


func _change_color() -> void :
	if multi_mesh_instance == null :
		return
	if multi_mesh_instance.material_override == null :
		multi_mesh_instance.material_override = SpatialMaterial.new()
		multi_mesh_instance.material_override.flags_transparent = true
		
	var mat : SpatialMaterial = multi_mesh_instance.material_override
	mat.albedo_color = color
	mat.albedo_color.a = opacity

func _ready() -> void:
	multi_mesh_instance.translation = Vector3.ZERO
	multi_mesh_instance.scale = Vector3.ONE
	
	var multimesh : MultiMesh = multi_mesh_instance.multimesh
	var mesh : CubeMesh = multimesh.mesh
	mesh.size = cell_size * 0.9
	
	_change_color()

func _update_draw(rect : Rect2) -> void :
	var multimesh : MultiMesh = multi_mesh_instance.multimesh
	multimesh.instance_count = int(rect.size.x * rect.size.y)
	for x in rect.size.x :
		for y in rect.size.y :
			var mesh_transform = Transform(
				Basis(),
				Vector3(x * cell_size.x , 0, y * cell_size.z )
			)
			multimesh.set_instance_transform(y * rect.size.x + x, mesh_transform)
	

func destroy() -> void :
	animation.play("hide")

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	emit_signal("finished", grid_rect)
	if not self.is_queued_for_deletion() :
		self.queue_free()
	pass # Replace with function body.
