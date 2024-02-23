extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	if 'despawn' in actor:
		actor.despawn()
		return SUCCESS
	return FAILURE

