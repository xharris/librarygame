extends ActionLeaf

@export var item_key:String

func tick(actor, blackboard: Blackboard):
	var inventory := actor.inventory as Inventory
	if not inventory or inventory.size() == 0:
		return FAILURE
	var item := inventory.get_all_items().front() as Item
	blackboard.set_value(item_key, item)
	return SUCCESS

