extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	if actor is Actor:
		actor.sit()
		return SUCCESS
	return FAILURE

