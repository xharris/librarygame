@icon('../icon/watch.svg')
class_name BTDelayer
extends BTDecorator

## When first executing the Delayer node, it will start an internal timer and 
## return RUNNING until the timer is complete, after which it will execute its 
## child node. The delayer resets its time after its child returns either 
## SUCCESS or FAILURE.

@export var duration:int
var _t = 0

func tick(actor:Node, data:Dictionary):
	if _t >= duration:
		_t = 0
		return super(actor, data)
	_t += get_physics_process_delta_time()
	return STATUS.RUNNING
