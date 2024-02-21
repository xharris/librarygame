extends Node

var GROUP = 'persistent'
var all_data:Dictionary = {}

func save_node(node:Node):
	# get save data
	if not 'save' in node:
		return
	var data := node.save() as Dictionary
	if not all_data.has(node.name):
		all_data[node.name] = {}
	all_data[node.name][node.get_instance_id()] = data

func get_all_type_data(type:String) -> Array[Dictionary]:
	return (all_data.get(type, {}) as Dictionary).values()
	
func write():
	# write to file
	for type in all_data:
		for id in all_data[type]:
			var save_path = "user://persistent/%s/%s.save"%[type,id]
			var type_dir = DirAccess.open("user://")
			type_dir.make_dir_recursive("persistent/%s"%[type])
			var save_file = FileAccess.open(save_path, FileAccess.WRITE)
			save_file.store_string(JSON.stringify(all_data))
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
							var load_path = "user://persistent/%s/%s.save"%[folder_name, file_name]
							var data = FileAccess.open(load_path, FileAccess.READ)
							all_data[folder_name][file_name.replace('.save','')] = JSON.parse_string(data.get_as_text())
						file_name = type_dir.get_next()
			folder_name = dir.get_next()

func _notification(what):
	if what in [NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST]:
		# save all persistent nodes
		for node in get_tree().get_nodes_in_group(GROUP):
			save_node(node)
		write()
