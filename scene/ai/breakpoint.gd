extends ActionLeaf

@export var enabled = true

func tick(actor, blackboard: Blackboard):
	if enabled:
		return SUCCESS
	return SUCCESS

