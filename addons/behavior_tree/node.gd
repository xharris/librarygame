class_name BTNode
extends BehaviorTree

enum STATUS { RUNNING, SUCCESS, FAILURE }
var l = Log.new(Log.LEVEL.DEBUG)
var _actor:Node
var _last_message:String = '(o.o)"'
var _last_status:STATUS = -1

func _log_response(status:STATUS, message:String = '') -> STATUS:
	if status != _last_status and message != _last_message:
		l.debug('%s %s %s', [_actor.name+':'+str(_actor.get_instance_id()), STATUS.find_key(status), message])
		_last_message = message
		_last_status = status
	return status

func running(message:String = '') -> STATUS:
	return _log_response(STATUS.RUNNING, message)
	
func failure(message:String = '') -> STATUS:
	return _log_response(STATUS.FAILURE, message)
	
func success(message:String = '') -> STATUS:
	return _log_response(STATUS.SUCCESS, message)

func _enter_tree():
	var parent = get_parent()
	if "_actor" in parent:
		_actor = parent._actor
	l.stack_offset = 2

func tick(actor, data:Dictionary) -> STATUS:
	return STATUS.FAILURE
