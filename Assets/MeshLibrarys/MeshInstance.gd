tool
extends MeshInstance


export(PoolVector3Array) var vertices : PoolVector3Array = PoolVector3Array()
export(PoolVector2Array) var UVs : PoolVector2Array = PoolVector2Array()
export(SpatialMaterial) var mat : SpatialMaterial = SpatialMaterial.new()
export(Color) var color : Color = Color(0.9, 0.1, 0.1)

export(bool) var upd = false setget set_upd
func set_upd(val : bool) -> void :
	upd = false
	if val :
		_upd()

export(bool) var upd_custom = false setget set_upd_custom
func set_upd_custom(val : bool) -> void :
	upd_custom = false 
	if val :
		_upd_custom()


func _upd():
	vertices.push_back(Vector3(1,0,0))
	vertices.push_back(Vector3(1,0,1))
	vertices.push_back(Vector3(0,0,1))
	vertices.push_back(Vector3(0,0,0))
	
	vertices.push_back(Vector3(0,2,0))
	vertices.push_back(Vector3(1,2,0))
	vertices.push_back(Vector3(1,0,0))
	vertices.push_back(Vector3(0,0,0))

	UVs.push_back(Vector2(0,0))
	UVs.push_back(Vector2(0,1))
	UVs.push_back(Vector2(1,1))
	UVs.push_back(Vector2(1,0))
	UVs.push_back(Vector2(1,0))
	UVs.push_back(Vector2(1,3))
	UVs.push_back(Vector2(3,3))
	UVs.push_back(Vector2(3,1))
	
	_upd_custom()

func _upd_custom() -> void :
	
	self.mesh = null
	var _mesh : Mesh = Mesh.new()
	
	mat.albedo_color = color

	var st : SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_FAN)
	st.set_material(mat)

	for v in vertices.size(): 
		st.add_color(color)
		st.add_uv(UVs[v])
		st.add_vertex(vertices[v] - Vector3(0.5, 0.0, 0.5))

	st.commit(_mesh)

	self.mesh = _mesh
