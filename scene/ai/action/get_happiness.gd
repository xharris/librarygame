extends ActionLeaf

@export var happiness_key:String

func tick(actor, blackboard: Blackboard):
	if actor is Actor:
		blackboard.set_value(happiness_key, actor.happiness)
		return SUCCESS
	return FAILURE

