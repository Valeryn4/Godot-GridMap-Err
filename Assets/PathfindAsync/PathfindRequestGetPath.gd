extends PathfindRequest
class_name PathfindRequestGetPath


func set_answer(result_ : PoolVector3Array) -> void :
	result = result_
	_completed = true
	emit_signal("completed")

func get_result() -> PoolVector3Array :
	return result as PoolVector3Array
