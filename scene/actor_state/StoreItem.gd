extends State

@export var nav_agent: NavigationAgent2D
@export var actor: Actor

var item:Item
var found_inventory:Inventory

func enter(args:Dictionary):
	var item_id := args.get('item_id') as int
		
	actor.move_speed = 50
	item = actor.inventory.get_items(item_id).front()
	if not item:
		return fsm.set_state('Idle')
	# find inventory (that doesnt belong to a actor) containing item
	found_inventory = Inventory.find_closest(actor)
	if not found_inventory:
		actor.inventory.drop_item(item_id)
		return fsm.set_state('Idle')
	# move to inventory
	nav_agent.target_desired_distance = 20
	if not actor.move_to(found_inventory.node.global_position):
		_on_nav_target_reached()

func _on_nav_target_reached():
	if item.type == Item.ITEM_TYPE.BOOK and actor.has_item(item.id):
		actor.transfer_item(item.id, found_inventory.inventory)
	fsm.set_state('Idle')

