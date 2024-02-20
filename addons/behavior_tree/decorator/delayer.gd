@icon('../icon/watch.svg')
class_name BTDelayer
extends BTDecorator

## When first executing the Delayer node, it will start an internal timer and 
## return RUNNING until the timer is complete, after which it will execute its 
## child node. The delayer resets its time after its child returns either 
## SUCCESS or FAILURE.

@export var duration:int = 0
@export var duration_key:String = ''
var _t = 0

func transform(response:STATUS, data:Dictionary):
	var _duration = data.get(duration_key, duration) as int
	if _t >= duration:
		_t = 0
		return response
	_t += get_physics_process_delta_time()
	return running('Wait %ds' % [duration])
