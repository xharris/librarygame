extends ConditionLeaf

@export var type:Item.TYPE

func tick(actor, blackboard: Blackboard):
	var inventory := actor.inventory as Inventory
	if not inventory or inventory.has_item_type(type):
		return FAILURE
	return SUCCESS

