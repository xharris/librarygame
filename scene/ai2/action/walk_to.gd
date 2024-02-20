extends ActionLeaf

@export var target_key:String

var _target_reached = false

func tick(actor:Node, data:Blackboard):
	actor = actor as Actor
	if not actor:
		return FAILURE
	var walk_target = data.get_value(target_key)
	# parse target position
	var target_position:Vector2
	if walk_target is Vector2:
		target_position = walk_target
	elif walk_target is Node2D:
		target_position = walk_target.global_position
	else:
		return FAILURE
	if not actor.navigation.target_reached.is_connected(_on_target_reached):
		actor.navigation.target_reached.connect(_on_target_reached, CONNECT_ONE_SHOT)
	# arrived?
	if _target_reached:
		_target_reached = false
		actor.stop_moving()
		return SUCCESS
	# move to target
	actor.move_to(target_position)
	return RUNNING

func _on_target_reached():
	_target_reached = true
