extends PatronStateMachine

@export var nav_agent: NavigationAgent2D
@export var patron: Patron

var item:InventoryHelper.Item
var found_inventory:InventoryHelper.Inventory

func enter(item_filter:Callable):
	item = InventoryHelper.find_item(item_filter) as InventoryHelper.Item
	# find inventory (that doesnt belong to a patron) containing item
	var found_inventory := (
		InventoryHelper.find_inventory_with_item(item.id)
		.filter(func(i:InventoryHelper.Inventory): return not i.node is CharacterBody2D)
		.front() as InventoryHelper.Inventory
	)
	if not found_inventory:
		# TODO lose happiness
		get_parent().set_state('Idle')
	# move to inventory
	nav_agent.target_position = found_inventory.node.global_position
	
func _on_nav_target_reached():
	if item.type == InventoryHelper.ITEM_TYPE.BOOK and found_inventory.has_item(item.id):
		get_parent().set_state('Read')
	else:
		get_parent().set_state('Idle')
