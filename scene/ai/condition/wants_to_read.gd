extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	actor = actor as Actor
	if not actor:
		return FAILURE
	if not actor.likes_genres.size():
		return FAILURE
	return SUCCESS

