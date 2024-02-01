extends State

var l = Log.new(Log.LEVEL.DEBUG)

@export var nav_agent: NavigationAgent2D
@export var actor: Actor

var item_template:Item.ItemTemplate
var found_inventory:Inventory

func item_not_found(happiness_loss:int):
	# TODO lose happiness
	get_parent().set_state('Walk')

func item_got():
	if fsm.get_task_manager().start_next_task():
		return
	fsm.set_state('Walk')

func enter(args:Dictionary):
	var item_filter := args.get('item_filter', Global.CALLABLE_TRUE) as Callable
	var happiness_loss := args.get('happiness_loss', 0) as int
	
	fsm.actor.move_speed = 50
	item_template = Item.find_item(item_filter)
	if not item_template:
		l.debug('Item not found')
		return item_not_found(happiness_loss)
	# find inventory (that doesnt belong to a actor) containing item
	found_inventory = (
		Inventory.find_inventory_with_item(item_template.id)
		.filter(func(i:Inventory): return not i.node.is_in_group('actor'))
		.front() as Inventory
	)
	if not found_inventory:
		l.debug('Inventory not found, -%d happiness', [happiness_loss])
		return item_not_found(happiness_loss)
	# move to inventory
	if not fsm.actor.move_to(found_inventory.node.global_position):
		item_got()

func leave():
	found_inventory = null
	item_template = null

func _on_nav_target_reached():
	if found_inventory and item_template:
		found_inventory.transfer_item(item_template.id, fsm.inventory)
	item_got()
