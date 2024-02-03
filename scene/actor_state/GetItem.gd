extends State

var l = Log.new(Log.LEVEL.DEBUG)

var actor: Actor

var item_template:Item.ItemTemplate
var found_inventory:Inventory
var happiness_loss:int

func item_not_found():
	# TODO lose happiness
	fsm.set_state('Walk')

func item_got():
	if actor.start_next_task():
		return
	fsm.set_state('Walk')

func enter(args:Dictionary):
	actor = find_parent('Actor')
	actor.nav_agent.target_reached.connect(_on_nav_target_reached)
	actor.navigation_blocked.connect(_on_actor_navigation_blocked)
	
	var item_filter := args.get('item_filter', Global.CALLABLE_TRUE) as Callable
	happiness_loss = args.get('happiness_loss', 0) as int
	
	item_template = Item.find_item(item_filter)
	if not item_template:
		l.info('Item not found')
		return item_not_found()
		
	# find inventory (that doesnt belong to a actor) containing item
	found_inventory = (
		Inventory.find_inventory_with_item(item_template.id)
		.filter(func(i:Inventory): return not i.parent.is_in_group(Actor.GROUP))
		.front() as Inventory
	)
	if not found_inventory:
		l.info('Inventory not found, -%d happiness', [happiness_loss])
		return item_not_found
		
	# move to inventory
	if not actor.move_to(found_inventory.global_position):
		return item_not_found()

func leave():
	found_inventory = null
	item_template = null

func _on_nav_target_reached():
	if found_inventory and item_template:
		found_inventory.transfer_item(item_template.id, actor.inventory)
	item_got()

func _on_actor_navigation_blocked():
	item_not_found()
