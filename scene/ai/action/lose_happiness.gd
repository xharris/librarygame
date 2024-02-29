extends ActionLeaf

@export var loss:int = 10 # <-- This is loss

func tick(actor, blackboard: Blackboard):
	if actor is Actor:
		actor.happiness -= loss
	return SUCCESS

