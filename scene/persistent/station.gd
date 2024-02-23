extends PersistentData

func save() -> Dictionary:
	var node := get_parent() as Station
	return {
		'type':node.type
	}

func load_data(data:Dictionary):
	var node := get_parent() as Station
	node.type = data.get('type', node.type)
