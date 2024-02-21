extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	if 'save' in actor:
		actor.save()
	return SUCCESS

