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
	var other_inventory := blackboard.get_value(inventory_key) as Inventory
	var result:bool
	var from_inventory:Inventory
	var to_inventory:Inventory
	match direction:
		DIRECTION.FROM:
			from_inventory = other_inventory
			to_inventory = inventory
		DIRECTION.TO:
			from_inventory = inventory
			to_inventory = other_inventory
	if to_inventory.is_full() or not from_inventory.get_all_items().has(item):
		return FAILURE
	if not from_inventory.transfer_item(item, to_inventory):
		return FAILURE
	return SUCCESS

