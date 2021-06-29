extends SCPObject
class_name SCPInteractiveObject

signal click_object()
signal release_object()
signal activated_object()
signal diactivated_object()

var activeted := false
var is_pressed := false

func activate() -> void :
	print("Object ", self.name, " activated")
	activeted = true
	emit_signal("activated_object")

func diactivated() -> void :
	print("Object ", self.name, " diactivated")
	activeted = false
	emit_signal("diactivated_object")


func _on_Area_input_event(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton :
		if event.button_index == BUTTON_LEFT :
			if event.is_pressed() and not is_pressed :
				is_pressed = true
				print("Object ", self.name, " clicked")
				emit_signal("click_object")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton :
		if event.button_index == BUTTON_LEFT :
			if not event.is_pressed() and is_pressed :
				is_pressed = false
				print("Object ", self.name, " released")
				emit_signal("release_object")
