extends State

@export var nav_agent: NavigationAgent2D
@export var actor: Actor

var item:Item
var found_inventory:Inventory

func item_not_found(happiness_loss:int):
	# TODO lose happiness
	get_parent().set_state('Idle')

func enter(args:Dictionary):
	var item_filter := args.get('item_filter', Callable()) as Callable
	var happiness_loss := args.get('happiness_loss', 0) as int
	
	actor.move_speed = 50
	item = Item.find_item(item_filter)
	if not item:
		return item_not_found(happiness_loss)
	# find inventory (that doesnt belong to a actor) containing item
	found_inventory = (
		Inventory.find_inventory_with_item(item.id)
		.filter(func(i:Inventory): return not i.node.is_in_group('actor'))
		.front() as Inventory
	)
	if not found_inventory:
		return item_not_found(happiness_loss)
	# move to inventory
	nav_agent.target_desired_distance = 20
	if not actor.move_to(found_inventory.node.global_position):
		_on_nav_target_reached()

func _on_nav_target_reached():
	if fsm.get_task_manager().start_next_task():
		return
	else:
		fsm.set_state('Idle')
