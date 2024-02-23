extends PersistentData

func save() -> Dictionary:
	var node := get_parent() as Actor
	return {
		'actor_name':node.actor_name,
		'role':node.role,
		'happiness':node.happiness,
		'inventory':node.inventory.get_instance_id(),
		'is_active':node.is_active()
	}

func load_data(data:Dictionary):
	var node:Actor = get_parent()
	node.role = data.get('role', node.role)
	node.happiness = data.get('happiness', node.happiness)
	if data.has('inventory'):
		var inventory = Persistent.load_node('Inventory', data.get('inventory'), node.inventory)
		node.inventory = inventory
	if not data.get('is_active', true) or not data.has('global_position'):
		node.despawn()
	else:
		node.global_position = data.get('global_position')
