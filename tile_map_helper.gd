extends Node

var scn_map_tile = preload("res://scene/map_tile.tscn")

func get_layer_by_name(tilemap:Map, layer_name:String):
	var layer_count = tilemap.get_layers_count()
	for l in range(layer_count):
		if tilemap.get_layer_name(l) == layer_name:
			return l
	return -1

class RandomTile:
	var tilemap: Map
	var cell: Vector2i
	func is_valid():
		return tilemap != null && cell != null
	func map_to_global():
		return tilemap.to_global(tilemap.map_to_local(cell))

func get_random_tilemap_cell(filter: Callable = Callable()) -> RandomTile:
	var tilemap := get_tree().get_nodes_in_group(Map.GROUP).front() as Map
	var rand_tile = RandomTile.new()
	if tilemap:
		rand_tile.tilemap = tilemap
		var cells = tilemap.get_used_cells(0)
		if filter.is_valid():
			cells = cells.filter(filter.bind(tilemap))
		if cells.size():
			rand_tile.cell = cells.pick_random()
	return rand_tile

func drop_item(inventory:Inventory, item_id:int):
	var tilemap := get_tree().get_nodes_in_group(Map.GROUP).front() as Map
	# get closest cell
	var map_layer = get_layer_by_name(tilemap, 'map')
	var cells = tilemap.get_used_cells(map_layer)
	cells.sort_custom(func(a:Vector2i,b:Vector2i): 
		return 	inventory.global_position.distance_to(tilemap.to_global(tilemap.map_to_local(a))) < \
				inventory.global_position.distance_to(tilemap.to_global(tilemap.map_to_local(b)))
	)
	var closest_cell = cells.front()
	# get/create tile_object
	var map_tile := get_tree().get_nodes_in_group(MapTile.GROUP).filter(func(t:MapTile): return t.cell == closest_cell).front() as MapTile
	if not map_tile:
		map_tile = scn_map_tile.instantiate()
		map_tile.cell = closest_cell
		map_tile.global_position = tilemap.to_global(tilemap.map_to_local(closest_cell))
		tilemap.add_child(map_tile)
		inventory.transfer_item(item_id, map_tile.inventory)

func get_all_instances() -> Array[Map]:
	var instances:Array[Map]
	instances.assign(get_tree().get_nodes_in_group(Map.GROUP))
	return instances

func get_current_map() -> Map:
	return get_tree().get_nodes_in_group(Map.GROUP).front() as Map
