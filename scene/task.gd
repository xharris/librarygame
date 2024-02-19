# meta-name: Task
class_name Task
extends State

static var l = Log.new(Log.LEVEL.DEBUG)
static var _scn_tasks:Dictionary = {}
static var TASKS_PATH = 'res://task'
static var SECTION = 'task'

static func _static_init():
	for task_file in DirAccess.get_files_at(TASKS_PATH):
		if task_file.ends_with('.tscn'):
			var scene = load(TASKS_PATH+'/'+task_file)
			_scn_tasks[task_file.replace('.tscn', '')] = scene

static func create_by_name(task_name:String, args:Dictionary = {}) -> Task:
	if not _scn_tasks.has(task_name):
		return
	var scene := _scn_tasks[task_name] as PackedScene
	return scene.instantiate() as Task

class Step:
	var state_name:String
	var state_args:Dictionary = {}

var actor:Actor
var prep_steps:Array[Step] = []
var args:Dictionary = {}

func _ready():
	fsm = get_manager().fsm

func get_manager() -> TaskManager:
	return get_parent()

func is_task_needed() -> bool:
	return false

func can_start_task() -> bool:
	return true

func get_prep_steps():
	pass

func add_prep_state(state_name:String, args:Dictionary = {}):
	if state_name == name:
		l.warn('Skipping prep step "%s". Do not add Task itself as prep step.', [state_name])
		return
	var step = Step.new()
	step.state_name = state_name
	step.state_args = args
	prep_steps.append(step)
