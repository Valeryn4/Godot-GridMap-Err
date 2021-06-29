extends Spatial

signal click_global(pos)
signal click_grid(pos)


onready var selector = $MeshInstance
onready var timer_click : Timer = $TimerClick
onready var animation : AnimationPlayer = $AnimationPlayer

export(Vector3) var cell_size = Vector3.ONE * 2
export(Vector2) var size_world = Vector2.ONE * 16
export(bool) var active_build = false setget set_active_build
func set_active_build(val : bool) -> void :
	active_build = val
	_active_build()


export(int) var layer = 0

var half_cell : Vector3 = cell_size * 0.5
var current_grid_position_selector : Vector2 = Vector2.ONE
var current_global_pos : Vector3 = Vector3.ZERO

var is_pressed : bool = false

func _ready():
	half_cell = cell_size * 0.5
	pass

func _active_build() -> void :
	if active_build :
		selector.show()
		
	else :
		selector.hide()

func _get_layer() -> float :
	return layer * cell_size.y





func _move_cursor_event(event : InputEventGrid) -> void :
	var grid_position : Vector3 = GridTransform.pos_to_grid_v3(event.position_world, half_cell)
	current_grid_position_selector = Vector2(
		clamp(grid_position.x, 0, size_world.x * 2), 
		clamp(grid_position.z, 0, size_world.y * 2)
	)
	
	var world_from_grid_position : Vector3 = GridTransform.grid_to_pos_v3(grid_position, half_cell)
	current_global_pos = world_from_grid_position
	self.translation = Vector3(
		world_from_grid_position.x,
		layer * cell_size.y, 
		world_from_grid_position.z
	)

func _pressed() -> void :
	if is_pressed :
		emit_signal("click_global", current_global_pos)
		emit_signal("click_grid", current_grid_position_selector)
		animation.play("click")

func _pressed_cursor_event(event : InputEventGridButton) -> void :
	match event.button_idx :
		BUTTON_LEFT :
			if event.is_pressed() :
				if not is_pressed :
					is_pressed = true
					timer_click.start()
					print("CursorPoint pressed")
			else :
				if is_pressed :
					_pressed()
					is_pressed = false
					print("CursorPoint released")


func _input(event: InputEvent) -> void:
	if not active_build :
		return
	
	if event is InputEventGrid :
		_move_cursor_event(event)
		if event is InputEventGridButton :
			_pressed_cursor_event(event)



func _on_TimerClick_timeout() -> void:
	is_pressed = false
