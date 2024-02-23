extends PersistentData

func save() -> Dictionary:
	var node := get_parent() as Item
	return {
		'id':node.id,
		'item_name':node.item_name,
		'args':node.args
	}

func load_data(data:Dictionary):
	var node := get_parent() as Item
	node.id = data.get('id', node.id)
	node.item_name = data.get('item_name', node.item_name)
	node.args = data.get('args', node.args)
