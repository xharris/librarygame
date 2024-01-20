class_name TaskManager
extends Node

var fsm:ActorStateMachine
var queue:Array[Task]

func _enter_tree():
	var parent = get_parent().find_child('ActorStateMachine') as ActorStateMachine
	if parent:
		fsm = parent
		var children = get_children()
		parent.add_states(children)

func size():
	return queue.size()

func _get_needed_tasks():
	var tasks = get_children().filter(func(t:Task): return t is Task) as Array[Task]
	for task in tasks:
		if task.is_task_needed() and not queue.any(func(t:Task): return t == task):
			if fsm:
				print(fsm.name,"+!",task.name)
			queue.append(task)

## returns true if a new task has been started
func start_next_task() -> bool:
	_get_needed_tasks()
	var tasks := queue.filter(func(t:Task):return t.required_previous_state.has(fsm.current_state_name))
	var task = tasks.pop_front()
	if task:
		fsm.set_state(task.name)
		return true
	return false

func start_random_task() -> bool:
	var task = get_children().filter(func(t:Task): return t is Task and t.random_pickable).pick_random()
	if task:
		queue.append(task)
		return start_next_task()
	return false
