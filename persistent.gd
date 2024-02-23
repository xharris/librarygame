extends Node

var l = Log.new()
var GROUP = 'persistent'
var all_data:Dictionary = {}
var packed_scenes:Dictionary = {
	'Actor':preload('res://scene/actor.tscn'),
	'Inventory':preload('res://scene/inventory.tscn'),
	'Item':preload('res://scene/item.tscn'),
	'Station':preload('res://scene/station.tscn'),
}
var enabled = false

func _get_persistent_data(node:Node) -> PersistentData:
	if node is PersistentData:
		return node
	else:
		return node.find_child('PersistentData')

func save_node(node:Node2D):
	# get save data
	var node_name = node.name
	var node_id = node.get_instance_id()
	var node_position = node.global_position
	var data_node := node.find_child('PersistentData') as PersistentData
	if not data_node:
		return l.error("Couldn't save %s",[node])
	var data := data_node.save() as Dictionary
	if not data.has('id'):
		data['id'] = node_id
	if not data.has('name'):
		data['name'] = node_name
	if node_position and not data.has('global_position'):
		data['global_position'] = node_position
	# put data in dictionary
	if not all_data.has(node_name):
		all_data[node_name] = {}
	all_data[node_name][node_id] = data

func load_node(type:String, id:String, replace:Node2D = null) -> Node2D:
	# instantiate from scene
	if not packed_scenes.has(type):
		return l.warn("Couldn't find packed scene for %s", [type])
	var scene = packed_scenes.get(type) as PackedScene
	var node = scene.instantiate()
	# load data
	var data = get_data(node.name, id)
	var persistent_data = _get_persistent_data(node)
	if not persistent_data:
		return l.warn("Couldn't load %s, id=%s", [node, id])
	persistent_data.load_data(data)
	# replace node?
	if replace:
		replace.replace_by(node, true)
	return node

func get_data(type:String, id:String) -> Dictionary:
	return (all_data.get(type, {}) as Dictionary).get(id, {})

func get_all_type_data(type:String) -> Array[Dictionary]:
	return (all_data.get(type, {}) as Dictionary).values()
	
func write():
	if not enabled:
		return
	# write to file
	for type in all_data:
		for id in all_data[type]:
			var save_path = "user://persistent/%s/%s.save"%[type,id]
			var type_dir = DirAccess.open("user://")
			type_dir.make_dir_recursive("persistent/%s"%[type])
			var save_file = FileAccess.open(save_path, FileAccess.WRITE)
			save_file.store_string(JSON.stringify(all_data[type][id]))
			save_file.close()

func _ready():
	# load
	var dir = DirAccess.open("user://persistent")
	if dir:
		# iterate types
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		while folder_name != '':
			if dir.current_is_dir():
				var type_dir = DirAccess.open("user://persistent/%s"%[folder_name])
				if type_dir:
					if not all_data.has(folder_name):
						all_data[folder_name] = {}
					# iterate .save files
					type_dir.list_dir_begin()
					var file_name = type_dir.get_next()
					while file_name != '':
						if file_name.ends_with(".save"):
							# import .save file
							var load_path = "user://persistent/%s/%s"%[folder_name, file_name]
							var data = FileAccess.open(load_path, FileAccess.READ)
							all_data[folder_name][file_name.replace('.save','')] = JSON.parse_string(data.get_as_text())
						file_name = type_dir.get_next()
			folder_name = dir.get_next()

func _notification(what):
	if what in [NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST]:
		# save all persistent nodes
		for node in get_tree().get_nodes_in_group(GROUP):
			save_node(node.get_parent())
		write()
