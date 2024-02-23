extends State

static var l = Log.new()

@export var actor: Actor

var item:Item
var found_inventory:Inventory

func enter(args:Dictionary):	
	var item_id := args.get('item_id') as int
	
	item = actor.inventory.get_items(item_id).front()
	if not item:
		l.debug('%s does not have item %d', [actor, item_id])
		return fsm.set_state('Idle')
	# find inventory (that doesnt belong to a actor) containing item
	found_inventory = Inventory.find_closest(actor, func(i:Inventory):return i.max_size > 0 and not i.parent.is_in_group(Actor.GROUP))
	if not found_inventory:
		actor.inventory.drop_item(item_id)
		return fsm.set_state('Idle')
	l.debug('%s found inventory %s', [actor, found_inventory])
	# move to inventory
	if not actor.move_to(found_inventory.global_position):
		fsm.set_state('Idle')

func leave():
	item = null
	found_inventory = null

func _on_nav_target_reached():
	if actor.inventory.has_item(item.id):
		actor.inventory.transfer_item(item.id, found_inventory)
	fsm.set_state('Walk')

func _on_actor_navigation_blocked():
	actor.inventory.drop_item(item.id)
	fsm.set_state('Walk')
