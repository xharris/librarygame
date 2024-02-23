extends AddCardsButton

@export var resource_path:String
@export var place_at_entrance:bool

func get_card_objects():
	# Gather available scenes
	var scene_dir = DirAccess.open(resource_path)
	var scenes:Array[PackedScene] = []
	for path in scene_dir.get_files():
		if path.ends_with('.tscn'):
			var scene = load(resource_path+'/'+path)
			scenes.append(scene)
	return scenes

func _on_place_object(event:InputEvent, global_position:Vector2, map_position:Vector2i, map:Map, object:PackedScene):
	if map.is_tile_empty(map_position):
		var new_object := object.instantiate()
		new_object.global_position = global_position
		map.add_child(new_object)

var _last_place_object:Callable
func on_card_pressed(event:InputEvent, card:SmallCard):
	var map = TileMapHelper.get_current_map() as Map
	if not map:
		return
	if place_at_entrance:
		# place entity at entrance (actor)
		map.selection_enabled = false
		var entrances = map.get_tile_coords(Map.TILE_NAME.ENTRANCE)
		if not entrances.size():
			l.warn('No entrances found to spawn actor')
			return
		var new_object := (card.object as PackedScene).instantiate()
		new_object.global_position = entrances.front()
		map.add_child(new_object)
	else:
		# allow user to place entity on map
		map.selection_enabled = true
		map.tile_outline_color = Palette.Blue500
		if _last_place_object:
			map.tile_select.disconnect(_last_place_object)
		_last_place_object = _on_place_object.bind(map, card.object as PackedScene)
		map.tile_select.connect(_last_place_object)
