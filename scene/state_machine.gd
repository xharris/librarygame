class_name StateMachine
extends Node

var initial_state: String
var current_state: Node
var states:Array[Node] = []
var last_process_mode:Dictionary = {}
var connections:Dictionary = {}

func _disable_state(node:Node):
	remove_child(node)
	last_process_mode[node.name] = node.process_mode
	node.process_mode = Node.PROCESS_MODE_DISABLED
	connections[node.name] = node.get_incoming_connections()
	for connection in node.get_incoming_connections():
		var sig:Signal = connection.get('signal')
		var cal:Callable = connection.get('callable')
		var flags:int = connection.get('flags')
		sig.disconnect(cal)

func _enable_state(node:Node):
	node.process_mode = last_process_mode.get(node.name, node.process_mode)
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
		_enable_state(current_state)
		state_callv('enter', args)

func get_states():
	states = get_children()

func _ready():
	get_states()
	for child in get_children():
		(child as Object).set('fsm', self)
		_disable_state(child)
