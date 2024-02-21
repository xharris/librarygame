extends ConditionLeaf

@export var role:Actor.ACTOR_ROLE

func tick(actor, blackboard: Blackboard):
	if actor is Actor and actor.role == role:
		return SUCCESS
	return FAILURE
