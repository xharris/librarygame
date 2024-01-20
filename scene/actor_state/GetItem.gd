extends Node

var fsm: ActorStateMachine
@export var nav_agent: NavigationAgent2D
@export var actor: Actor

var item:InventoryHelper.Item
var found_inventory:InventoryHelper.Inventory

func item_not_found(happiness_loss:int):
	# TODO lose happiness
	get_parent().set_state('Idle')

func enter(args:Dictionary):
	var item_filter := args.get('item_filter', Callable()) as Callable
	var happiness_loss := args.get('happiness_loss', 0) as int
	
	actor.move_speed = 50
	item = InventoryHelper.find_item(item_filter) as InventoryHelper.Item
	if not item:
		return item_not_found(happiness_loss)
	# find inventory (that doesnt belong to a actor) containing item
	found_inventory = (
		InventoryHelper.find_inventory_with_item(item.id)
		.filter(func(i:InventoryHelper.Inventory): return not i.node.is_in_group('actor'))
		.front() as InventoryHelper.Inventory
	)
	if not found_inventory:
		return item_not_found(happiness_loss)
	# move to inventory
	nav_agent.target_desired_distance = 20
	nav_agent.target_position = found_inventory.node.global_position

func _on_nav_target_reached():
	if item.type == InventoryHelper.ITEM_TYPE.BOOK and found_inventory.has_item(item.id):
		found_inventory.transfer_item(item.id, actor.inventory)
		fsm.set_state('Sit')
	else:
		fsm.set_state('Idle')
