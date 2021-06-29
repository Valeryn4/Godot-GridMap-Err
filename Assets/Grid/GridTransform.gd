extends Reference
class_name GridTransform



static func pos_to_grid_v3(from_pos : Vector3, cell_size : Vector3) -> Vector3 :
	var cell_pos : Vector3 = Vector3(
		ceil(from_pos.x / cell_size.x),
		ceil(from_pos.y / cell_size.y),
		ceil(from_pos.z / cell_size.z)
	)
	return cell_pos


static func pos_to_grid_v2(from_pos : Vector2, cell_size : Vector2) -> Vector2 :
	var cell_pos : Vector2 = Vector2(
		ceil(from_pos.x / cell_size.x),
		ceil(from_pos.y / cell_size.y)
	) 
	return cell_pos


static func grid_to_pos_v3(from_pos_grid : Vector3, cell_size : Vector3) -> Vector3 :
	var to : Vector3 = from_pos_grid * cell_size - (cell_size * 0.5)
	return to

static func grid_to_pos_v2(from_pos_grid : Vector2, cell_size : Vector2) -> Vector2 :
	var to : Vector2 = from_pos_grid * cell_size - (cell_size * 0.5)
	return to

static func vec2_to_vec3(vec2 : Vector2, y : float = 0) -> Vector3 :
	return Vector3(vec2.x, y, vec2.y)

static func vec3_to_vec2(vec3 : Vector3) -> Vector2 :
	return Vector2(vec3.x, vec3.z)

static func clamp_vec2(value : Vector2, min_val : Vector2, max_val : Vector2) -> Vector2 :
	return Vector2(
		clamp(value.x, min_val.x, max_val.x),
		clamp(value.y, min_val.y, max_val.y)
	)

static func clamp_vec3(value : Vector3, min_val : Vector3, max_val : Vector3) -> Vector3 :
	return Vector3(
		clamp(value.x, min_val.x, max_val.x),
		clamp(value.y, min_val.y, max_val.y),
		clamp(value.z, min_val.z, max_val.z)
	)

