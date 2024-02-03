class_name TaskManager
extends Node

static var l = Log.new()

@export var fsm:StateMachine
var queue:Array[Task] = []
var current_task:Task
var prep_steps:Array[Task.Step] = []

func size():
	return queue.size()

func get_all_tasks() -> Array[Task]:
	var tasks:Array[Task]
	tasks.assign(get_children().filter(func(t:Task): return t is Task))
	return tasks

func find_task(task_name:String) -> Task:
	var tasks = get_all_tasks()
	return tasks.filter(func(t:Task):return t.name == task_name).front()

func _get_needed_tasks():
	var actor := find_parent('Actor') as Actor
	var tasks = get_all_tasks()
	queue = queue.filter(func(t:Task):return t.is_task_needed())
	for task in tasks:
		if task.is_task_needed() and not queue.any(func(t:Task): return t.name == task.name):
			l.debug('%s+!%s', [actor, task.name])
			queue.append(task)

## returns true if a task is in progress
func start_next_task() -> bool:
	var actor := find_parent('Actor') as Actor
	_get_needed_tasks()
	if not current_task:
		current_task = queue.pop_front() as Task
		if not current_task:
			# still don't have a task to do
			prep_steps = []
			return false
		current_task.fsm = fsm
		# populate task steps
		current_task.get_prep_steps()
		prep_steps = current_task.prep_steps
	if prep_steps.size():
		# do next prep step
		var step := prep_steps.pop_front() as Task.Step
		l.debug('%s prep step %s %s', [actor, step.state_name, step.state_args])
		fsm.set_state(step.state_name, step.state_args)
		return true
	fsm.set_state_node(current_task)
	l.debug('%s!>%s',[actor,current_task.name])
	current_task = null
	return true
