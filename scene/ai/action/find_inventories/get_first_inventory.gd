extends ActionLeaf

@export var inventories_key:String = 'inventories'
@export var inventory_key:String = 'inventory'

func tick(actor, blackboard: Blackboard):
	var inventories := blackboard.get_value(inventories_key) as Array[Inventory]
	if not inventories.size():
		return FAILURE
	blackboard.set_value(inventory_key, inventories.front())
	return SUCCESS
