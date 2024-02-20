extends BTAction

@export var item_id_key:String
@export var inventory_key:String

func tick(actor:Actor, data:Dictionary) -> STATUS:
	var item_id := data.get(item_id_key) as int
	var inventory := data.get(inventory_key) as Inventory
	if inventory.transfer_item(item_id, actor.inventory):
		return STATUS.SUCCESS
	return STATUS.FAILURE
