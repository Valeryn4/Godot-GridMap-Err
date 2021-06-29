extends Node

var enemy_workers := {}

func add_enemy(enemy : SCPEnemy) -> void :
	enemy_workers[enemy] = []

func remove_enemy(enemy : SCPEnemy) -> void :
	if not enemy_workers.erase(enemy) :
		push_warning("EnemyAI erase null workers!!!") 

func push_work(work : IWorks) -> void :
	var works : Array = enemy_workers[work.enemy]
	var old_work : IWorks = null
	if not works.empty() :
		old_work = works.front()
	works.append(work)
	works.sort_custom(self, "sort_works")
	var current_work : IWorks = works.front()
	if old_work != null and old_work != current_work :
		old_work.is_running = false
		current_work.is_running = false
	print("Push work")

func sort_works(work1 : IWorks, work2 : IWorks) -> bool :
	return work1.priority < work2.priority 

func pop_work(enemy : SCPEnemy) -> void :
	enemy_workers[enemy].pop_front()
	print("Pop work")

func _physics_process(delta: float) -> void:
	for works in enemy_workers.values() :
		if not works.empty() :
			var work : IWorks = works.front()
			if work.is_finished :
				pop_work(work.enemy)
			else :
				work.custom_physics_process(delta)
