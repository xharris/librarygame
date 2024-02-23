extends PersistentData

func save() -> Dictionary:
	var node := get_parent() as Inventory
	return {
		'items':node.get_all_items().map(func(i:Item):return i.get_instance_id())
	}

func load_data(data:Dictionary):
	var node := get_parent() as Inventory
	if data.has('items'):
		var items = data.get('items', []) as Array
		for item in items:
			var item_node := Persistent.load_node('Item', item) as Item
			if item_node:
				node.add_item(item_node)
