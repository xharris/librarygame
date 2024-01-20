class_name StateMachine
extends Node

var initial_state: String
var current_state: State
var current_state_name = ''
var states:Array[State] = []
var last_process_mode:Dictionary = {}
var connections:Dictionary = {}

signal add_state(node:State)
signal change_state(node:State)

func _disable_state(node:Node):
	if not node is State:
		return
	remove_child(node)
	last_process_mode[node.name] = node.process_mode
	node.process_mode = Node.PROCESS_MODE_DISABLED
	# disconnect signals
	connections[node.name] = node.get_incoming_connections()
	for connection in node.get_incoming_connections():
		var sig:Signal = connection.get('signal')
		var cal:Callable = connection.get('callable')
		sig.disconnect(cal)

func _enable_state(node:Node):
	if not node is State:
		return
	node.process_mode = last_process_mode.get(node.name, node.process_mode)
	# reconnect signals
	if connections.has(node.name):
		for connection in connections[node.name]:
			var sig:Signal = connection.get('signal')
			var cal:Callable = connection.get('callable')
			var flags:int = connection.get('flags')
			sig.connect(cal, flags)
	add_child(node)

func state_callv(method_name:String, args:Dictionary = {}, state:Node = current_state):
	if state and state.has_method(method_name):
		state.callv(method_name, [args])

func set_state(state_name:String, args:Dictionary = {}):
	print(name,'->',state_name,args)
	# leave current state
	if current_state:
		state_callv('leave')
		_disable_state(current_state)
	# enter next state
	var next_state := states.filter(func(s:Node): return s.name == state_name).front() as Node
	if next_state:
		current_state = next_state
		current_state_name = current_state.name
		_enable_state(current_state)
		change_state.emit(current_state)
		state_callv('enter', args)
	else:
		push_error('State "',state_name,'" not found in ',states.map(func(s:State):return s.name))
	
func add_states(new_states:Array[Node]):
	for new_state in new_states:
		if new_state is State:
			(new_state as Object).set('fsm', self)
			_disable_state(new_state)
			states.append(new_state)
			print(name,'++',new_state.name)
			add_state.emit(new_state)

func _ready():
	add_states(get_children())
