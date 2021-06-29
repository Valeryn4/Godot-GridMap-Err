extends Control


signal change_build_mode(mode)
signal exit_game_zone()
signal entered_game_zone()

signal clear_game()

onready var button_setup = $HBoxContainer/Panel/VBox/HBoxSetup/CheckBoxSetup
onready var button_destroy = $HBoxContainer/Panel/VBox/HBoxDestroy/CheckBoxDestroy
onready var button_object = $HBoxContainer/Panel/VBox/HBoxSetupObject/CheckBoxStupObject
onready var button_set_path = $HBoxContainer/Panel/VBox/HBoxSetPath/CheckBoxSetPath
onready var game_zone = $HBoxContainer/VBoxContainer/Control

func _ready() -> void:
	var group = ButtonGroup.new()
	button_setup.set_button_group(group)
	button_destroy.set_button_group(group)
	button_object.set_button_group(group)
	button_set_path.set_button_group(group)
	emit_signal("change_build_mode", GridConsts.BUILD_MODE_ROOM_DEFAULT)
	
	var mouse_pos = self.get_global_mouse_position()
	if game_zone.get_global_rect().has_point(mouse_pos) :
		emit_signal("entered_game_zone")
	else :
		emit_signal("exit_game_zone")
	
	

func _on_CheckBoxSetup_toggled(button_pressed: bool) -> void:
	if button_pressed :
		emit_signal("change_build_mode", GridConsts.BUILD_MODE_ROOM_DEFAULT)


func _on_CheckBoxDestroy_toggled(button_pressed: bool) -> void:
	if button_pressed :
		emit_signal("change_build_mode", GridConsts.BUILD_MODE_REMOVE)


func _on_CheckBoxStupObject_toggled(button_pressed: bool) -> void:
	if button_pressed :
		emit_signal("change_build_mode", GridConsts.BUILD_MODE_SETUP_OBJECT)

func _on_Control_mouse_entered() -> void:
	emit_signal("entered_game_zone")


func _on_Control_mouse_exited() -> void:
	emit_signal("exit_game_zone")


func _on_CheckBoxSetPath_toggled(button_pressed: bool) -> void:
	if button_pressed :
		emit_signal("change_build_mode", GridConsts.BUILD_MODE_SET_PATH)
	pass # Replace with function body.


func _on_Button_pressed() -> void:
	emit_signal("clear_game")
	pass # Replace with function body.
