extends ActionLeaf

@export var inventories_key:String = 'inventories'
@export var item_type:Item.TYPE

func tick(actor, blackboard: Blackboard):
	var inventories := blackboard.get_value(inventories_key) as Array[Inventory]
	inventories = inventories.filter(func(i:Inventory):
		return i.has_item_type(item_type))
	blackboard.set_value(inventories_key, inventories)
	return SUCCESS

