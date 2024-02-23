extends ConditionLeaf

@export var role:Actor.ROLE

func tick(actor, blackboard: Blackboard):
	if actor is Actor and actor.role == role:
		return SUCCESS
	return FAILURE
