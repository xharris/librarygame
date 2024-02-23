extends BTAction

@export var item_id_key:String
@export var inventory_key:String
@export var ignore_actor_inventory:bool = true

func tick(actor, data:Dictionary) -> STATUS:
	var item_id := data.get(item_id_key) as int
	# find inventory (that doesnt belong to a actor) containing item
	var found_inventory = (
		Inventory.find_inventory_with_item(item_id)
		.filter(func(i:Inventory): return not ignore_actor_inventory or not i.parent.is_in_group(Actor.GROUP))
		.front() as Inventory
	)
	if not found_inventory:
		return failure("Couldn't find inventory")
	data[inventory_key] = found_inventory
	return success('Found inventory %s'%[found_inventory])
