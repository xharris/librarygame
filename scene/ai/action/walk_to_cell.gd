extends BTAction

@export var target_key:String

var _status = STATUS.RUNNING

func _reached():
	_status = STATUS.SUCCESS
	
func _blocked():
	_status = STATUS.FAILURE

func tick(actor:Actor, data:Dictionary) -> STATUS:
	var walk_target := data.get(target_key) as Vector2
	actor.move_to(walk_target)
	if actor.global_position.distance_to(walk_target) <= 1:
		actor.stop_moving()
		data.erase(target_key)
		return STATUS.SUCCESS
	return STATUS.RUNNING
