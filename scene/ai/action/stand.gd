extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	actor = actor as Actor
	if not actor: return FAILURE
	actor.stand()
	return SUCCESS

