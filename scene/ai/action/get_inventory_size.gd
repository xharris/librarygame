extends ActionLeaf

@export var size_key:String

func tick(actor, blackboard: Blackboard):
	var inventory := actor.inventory as Inventory
	if not inventory:
		return FAILURE
	var size = inventory.size()
	blackboard.set_value(size_key, size)
	return SUCCESS

