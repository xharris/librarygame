class_name StateMachine
extends Node

var current_state: Node
var states:Array[Node] = []
var state_stack:Array[Array] = []

func clear_stack():
	states = []
	return self
	
func push_state(state_name:String, args:Array = []):
	# get all states
	states = get_children()
	state_stack.append([state_name, args])
	return self

## args: Pass args to the next state (if it doesn't already have args)
func pop_state(args:Array = []):
	# leave current state
	if current_state:
		if current_state.has_method('leave'):
			current_state.callv('leave', args)
	for child in get_children():
		remove_child(child)
	var next_state_array = state_stack.pop_front()
	var next_state_name:String = next_state_array[0]
	var next_state_args:Array = next_state_array[1]
	if next_state_args.size() == 0:
		next_state_args = args
	var next_state := states.filter(func(s:Node): return s.name == next_state_name).front() as Node
	# enter next state
	if next_state:
		current_state = next_state
		add_child(current_state)
		if current_state.has_method('enter'):
			print('enter ',current_state.name)
			current_state.callv('enter', next_state_args)
	return self

func set_state(state_name:String, args:Array = []):
	clear_stack()
	push_state(state_name, args)
	pop_state()
	return self

func state_callv(name:String, args:Array = []):
	if current_state and current_state.has_method(name):
		current_state.callv(name, args)
