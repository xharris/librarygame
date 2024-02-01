extends State

@export var nav_agent: NavigationAgent2D
@export var actor: Actor
@export var inventory: Inventory

var item:Item
var found_inventory:Inventory

func enter(args:Dictionary):
	var item_id := args.get('item_id') as int
		
	actor.move_speed = 50
	item = inventory.get_items(item_id).front()
	if not item:
		return fsm.set_state('Idle')
	# find inventory (that doesnt belong to a actor) containing item
	found_inventory = Inventory.find_closest(actor)
	if not found_inventory:
		inventory.drop_item(item_id)
		return fsm.set_state('Idle')
	# move to inventory
	if not actor.move_to(found_inventory.node.global_position):
		fsm.set_state('Walk')

func leave():
	item = null
	found_inventory = null

func _on_nav_target_reached():
	if inventory.has_item(item.id):
		inventory.transfer_item(item.id, found_inventory)
	fsm.set_state('Walk')

func _on_actor_navigation_blocked():
	inventory.drop_item(item.id)
	fsm.set_state('Walk')
