extends Reference
class_name IWorks

var enemy : SCPEnemy = null
var is_finished : bool = false
var is_running : bool = false
var priority := 5

func _init(new_enemy : SCPEnemy) -> void :
	enemy = new_enemy

func custom_physics_process(delta : float) -> void :
	_custom_physics_process(delta)

func _custom_physics_process(_delta : float) -> void : #virtual
	pass
