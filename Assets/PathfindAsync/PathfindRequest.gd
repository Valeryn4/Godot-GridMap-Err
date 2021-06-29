extends Reference
class_name PathfindRequest

# warning-ignore:unused_signal
signal completed()

var result = null
export(int) var err : int = 0
var _completed = false

func answer() :
	if _completed :
		return result
	return null
