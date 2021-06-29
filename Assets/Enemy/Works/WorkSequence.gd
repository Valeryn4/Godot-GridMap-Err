extends IWorks
class_name WorkSequence

var sequence := []

func add_work_sequence(work : IWorks) -> void :
	sequence.append(work)

func _custom_physics_process(delta : float) -> void : #virtual
	if sequence.empty() :
		is_finished = true
	else :
		var work : IWorks = sequence.front()
		if work.is_finished :
			sequence.pop_front()
		else :
			work.custom_physics_process(delta)
