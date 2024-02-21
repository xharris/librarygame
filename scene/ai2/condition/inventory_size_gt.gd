extends ConditionLeaf

@export var size:int = 0
@export var size_key:String

func tick(actor, blackboard: Blackboard):
	var inventory := actor.inventory as Inventory
	if not inventory:
		return FAILURE
	var size := blackboard.get_value(size_key, size) as int
	if inventory.size() > size:
		return SUCCESS
	return FAILURE

