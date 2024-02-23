extends ActionLeaf

enum DIRECTION {FROM, TO}

@export var item_key:String
@export var inventory_key:String
@export var direction:DIRECTION

func tick(actor, blackboard: Blackboard):
	var inventory := actor.inventory as Inventory
	if not inventory:
		return FAILURE
	var item := blackboard.get_value(item_key) as Item
	if not inventory.get_all_items().has(item):
		return FAILURE
	var other_inventory := blackboard.get_value(inventory_key) as Inventory
	if other_inventory.is_full():
		return FAILURE
	var result:bool
	match direction:
		DIRECTION.FROM:
			result = other_inventory.transfer_item(item, inventory)
		DIRECTION.TO:
			result = inventory.transfer_item(item, other_inventory)
	if not result:
		return FAILURE
	return SUCCESS

