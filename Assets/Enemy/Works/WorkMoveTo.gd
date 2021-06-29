extends IWorks
class_name WorkMoveTo

var _current_target := Vector3.ZERO
var _target := Vector3.ZERO
var _index_path := 0
var _path : PoolVector3Array = []

var _pathfind_async : PathfindAsync = null

var _wait_path := false

func _init(new_enemy : SCPEnemy, target : Vector3, pathfind_async : PathfindAsync).(new_enemy) -> void:
	_target = target
	_pathfind_async = pathfind_async

func _request_path_to(to : Vector3) -> void :
	var ev := _pathfind_async.request_get_path(enemy.translation, to)
	ev.connect("completed", self, "_on_pathfind_result_data", [ev], CONNECT_ONESHOT)

func _on_pathfind_result_data(event : PathfindRequestGetPath) -> void :
	var path = event.answer()
	if path == null :
		_failed_move()
		return
	
	if path.empty() :
		_failed_move()
		return
	
	_update_path(path)
	
	pass

func _finish_move() -> void :
	is_finished = true

func _failed_move() -> void :
	is_finished = true

func _update_path(path : PoolVector3Array) -> void :
	_path = path
	_index_path = 0
	enemy.velocity.x = 0
	enemy.velocity.z = 0
	if not path.empty() :
		_current_target = _path[_index_path]
		_current_target.y = enemy.translation.y
	
	_wait_path = false

func _custom_physics_process(delta : float) -> void :
	if _wait_path :
		return
	
	if not is_running :
		is_running = true
		_wait_path = true
		_request_path_to(_target)
		return
	
	enemy.velocity.y -= enemy.gravity * delta
	_current_target.y = enemy.translation.y
	if _current_target != Vector3.ZERO :
		var direction = enemy.translation.direction_to(_current_target)
		var distance = enemy.translation.distance_to(_current_target)
		var mov = direction * enemy.movement * delta
		enemy.velocity.x = mov.x
		enemy.velocity.z = mov.z
		
		if distance <= 0.1 :
			_index_path += 1
			if _index_path >= _path.size() :
				_index_path = 0
				_current_target = Vector3.ZERO
				_path = []
				enemy.velocity.x = 0
				enemy.velocity.z = 0
				_finish_move()
			else :
				enemy.velocity.x = 0
				enemy.velocity.z = 0
				_current_target = _path[_index_path]
				_current_target.y = enemy.translation.y
		else :
			pass
			#print("OOOPS")
	
	enemy.velocity = enemy.move_and_slide(enemy.velocity, Vector3.UP)
