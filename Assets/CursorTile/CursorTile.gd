extends Spatial

"""

CURSOR! SELECT RECT BUILD ZONE!

"""

#emplace rect to grid signal
signal select_rect(rect)

const CURSOR_SELECTOR_PKG = preload("res://Assets/CursorTile/Selector.tscn")
const CURSOR_RECT_PKG = preload("res://Assets/CursorTile/CursorRect.tscn")
const NIL_POS_GRID = Vector2.INF


export(Color) var selector_color = Color.blue setget set_selector_color
func set_selector_color(val : Color) -> void :
	selector_color = val
	_update_selector_color()

export(Color) var select_zone_color = Color.green setget set_select_zone_color
func set_select_zone_color(val : Color) -> void :
	select_zone_color = val
	_update_select_zone_color()

export(Vector3) var cell_size : Vector3 = Vector3.ONE * 2.0
export(Vector2) var size_world : Vector2 = Vector2.ONE * 128

export(bool) var active_build = false setget set_active_build
func set_active_build(val : bool) -> void :
	active_build = val
	_active_build()

export(int) var current_layer = 0

var selector : Spatial = null
var cursor_rect : Spatial = null
var current_grid_position_selector : Vector2 = NIL_POS_GRID
var begin_grid_position_select : Vector2  = NIL_POS_GRID

func _ready():
	selector = CURSOR_SELECTOR_PKG.instance()
	self.add_child(selector)
	_update_selector_color()
	
	
	
	pass

func _update_selector_color() -> void :
	if selector != null :
		selector.color = selector_color


func _update_select_zone_color() -> void :
	if cursor_rect != null :
		cursor_rect.color = select_zone_color

static func _get_rect_from_two_point(begin : Vector2, end : Vector2) -> Rect2 :
	
	var x_min : float = min(begin.x, end.x)
	var x_max : float = max(begin.x, end.x)
	var x_size : float = x_max - x_min
	
	var y_min : float = min(begin.y, end.y)
	var y_max : float = max(begin.y, end.y)
	var y_size : float = y_max - y_min
	
	var rect = Rect2(
		x_min,
		y_min,
		x_size,
		y_size
	)
	return rect

func _get_layer() -> float :
	return current_layer * cell_size.y


func _move_cursor_to(event : InputEventGrid) -> void :
	
	var grid_position : Vector3 = event.position_grid
	current_grid_position_selector = Vector2(
		clamp(grid_position.x, 0, size_world.x),
		clamp(grid_position.z, 0, size_world.y)
	)
	
	
	var world_from_grid_position : Vector3 = event.position_world_center
	selector.translation = Vector3(
		clamp(world_from_grid_position.x, 0, size_world.x * cell_size.x),
		_get_layer() + 1, 
		clamp(world_from_grid_position.z, 0, size_world.y * cell_size.z)
	)

func _pressed_cursor(event : InputEventGridButton) -> void :
	match event.button_idx :
		BUTTON_LEFT :
			if event.is_pressed() :
				if begin_grid_position_select == NIL_POS_GRID :
					begin_grid_position_select = current_grid_position_selector
					print("PRESS")
			else :
				if begin_grid_position_select != NIL_POS_GRID :
					var end_grid_position_select = current_grid_position_selector
					_draw_rect(begin_grid_position_select, end_grid_position_select)
					_clean_rect()
					begin_grid_position_select = NIL_POS_GRID
					print("RELEASE")

func _input(event: InputEvent) -> void:
	if not active_build :
		return
	
	if event is InputEventGrid :
		_move_cursor_to(event)
		if begin_grid_position_select != NIL_POS_GRID :
			_draw_rect(begin_grid_position_select, current_grid_position_selector)
		
		if event is InputEventGridButton :
			_pressed_cursor(event)

func _clean_rect() -> void :
	if cursor_rect != null :
		if is_instance_valid(cursor_rect) :
				if not cursor_rect.is_queued_for_deletion() :
					cursor_rect.destroy()
		cursor_rect = null
	selector.show()

func _get_rect_world_from_rect_grid(rect : Rect2) -> Rect2 :
	var cell_size_v2 = GridTransform.vec3_to_vec2(cell_size)
	rect.position = GridTransform.grid_to_pos_v2(rect.position, cell_size_v2)
	rect.size = GridTransform.grid_to_pos_v2(rect.size, cell_size_v2)
	return rect

func _draw_rect(begin_position : Vector2, end_position : Vector2) -> void :
	
	var rect : Rect2 = _get_rect_from_two_point(begin_position,  end_position)
	rect.size += Vector2.ONE
	if rect.size.x <= 0 or rect.size.y <= 0 :
		return
	var world_rect = _get_rect_world_from_rect_grid(rect)
	
	selector.hide()
	if cursor_rect == null :
		cursor_rect = CURSOR_RECT_PKG.instance()
		_update_select_zone_color()
		self.add_child(cursor_rect)
		cursor_rect.connect("finished", self, "_emit_rect", [], CONNECT_DEFERRED)
	
	cursor_rect.translation = Vector3(world_rect.position.x, _get_layer() + 1, world_rect.position.y)
	cursor_rect.grid_rect = rect
	
	return

func _emit_rect(rect) -> void :
	if not active_build :
		return
	emit_signal("select_rect", rect)

func _active_build() -> void :
	if not active_build :
		if cursor_rect != null :
			if is_instance_valid(cursor_rect) :
				if not cursor_rect.is_queued_for_deletion() :
					cursor_rect.queue_free()
			cursor_rect = null
		selector.hide()
		begin_grid_position_select = NIL_POS_GRID
		current_grid_position_selector = NIL_POS_GRID
	else :
		selector.show()
