extends Spatial

"""

RTS Camera!
LEFT CLICK - CLICK
RIGHT CLICK - MOVE CAMERA
MIDDLE_CLICK - ROTATION CAMERA
ROT MIDDLE WHEEL - ZOOM

"""

export(float) var default_distance = 10.0
export(float) var defailt_v_rot = -45.0
export(float) var v_rot_min = -25.0
export(float) var v_rot_max = -90.0
export(float) var max_zoom = 20.0
export(float) var min_zoom = 5.0

export(float) var move_multipy = 0.025
export(float) var rot_h_multiply = 0.2

export(bool) var active_build = false setget set_active_build
func set_active_build(val : bool) -> void :
	active_build = val
	_active_build()

onready var camera = $Camera

enum CameraMode {
	NONE,
	ROT_HORIZONTAL,
	ROT_VERICAL,
	MOVE,
	BUILD
}

export(CameraMode) var current_mode = CameraMode.NONE
 

func _ready() -> void:
	zoom_camera(default_distance)
	rotation_camera(Vector3(defailt_v_rot, 0, 0))
	

func move_camera(pos : Vector3) -> void :
	self.translation = pos

func moved_camera(offset : Vector3) -> void :
	move_camera(self.translation + offset)

func zoom_camera(new_zoom : float) -> void :
	camera.translation.z = clamp(new_zoom, min_zoom, max_zoom)

func zoomed_camera(offset : float) -> void :
	zoom_camera(camera.translation.z + offset)

func rotation_camera(rot : Vector3) -> void :
	var new_rot = Vector3(
		clamp(rot.x, v_rot_max, v_rot_min),
		rot.y,
		rot.z
	)
	self.rotation_degrees = new_rot

func rotated_camera(offset : Vector3) -> void :
	rotation_camera(self.rotation_degrees + offset)

func _input(event: InputEvent) -> void:
	if not active_build :
		return
	if event is InputEventMouseButton :
		match event.button_index :
			BUTTON_WHEEL_UP :
				zoomed_camera(-1.0)
			BUTTON_WHEEL_DOWN :
				zoomed_camera(1.0)
			BUTTON_LEFT :
				pass
				#_select_mode_from_event_pressed(event.is_pressed(), CameraMode.MOVE)
			BUTTON_MIDDLE :
				_select_mode_from_event_pressed(event.is_pressed(), CameraMode.ROT_HORIZONTAL)
			BUTTON_RIGHT :
				_select_mode_from_event_pressed(event.is_pressed(), CameraMode.MOVE)
	
	if event is InputEventMouseMotion :
		match current_mode :
			CameraMode.MOVE :
				var relative_fixed : Vector2 = -event.relative * move_multipy
				relative_fixed = relative_fixed.rotated(-deg2rad(self.rotation_degrees.y))
				var offset : Vector3 = Vector3(relative_fixed.x, 0, relative_fixed.y)
				moved_camera(offset)
			CameraMode.ROT_HORIZONTAL :
				rotated_camera(Vector3(0, event.relative.x * rot_h_multiply, 0))
			CameraMode.ROT_VERICAL :
				rotated_camera(Vector3(-event.relative.y, 0, 0))


func _select_mode(new_mode : int) -> void :
	if current_mode == CameraMode.NONE :
		current_mode = new_mode
		print("Select camera mode to ", new_mode)

func _unselect_mode(old_mode : int) -> void :
	if current_mode == old_mode :
		current_mode = CameraMode.NONE
		print("Unselect camera mode from ", old_mode)

func _select_mode_from_event_pressed(pressed : bool, mode : int) -> void :
	if pressed :
		_select_mode(mode)
	else :
		_unselect_mode(mode)

func _active_build() -> void :
	
	pass
