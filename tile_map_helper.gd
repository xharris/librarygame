extends Node

var scn_tile_object = preload("res://scene/tile_object.tscn")

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
	var tilemap := get_tree().get_nodes_in_group('tilemap').front() as Map
	var rand_tile = RandomTile.new()
	if tilemap:
		var map_layer = get_layer_by_name(tilemap, 'map')
		rand_tile.tilemap = tilemap
		var cells = tilemap.get_used_cells(map_layer)
		if filter.is_valid():
			cells = cells.filter(filter)
		rand_tile.cell = cells.pick_random()
	return rand_tile

func drop_item(inventory:InventoryHelper.Inventory, item_id:int):
	var tilemap := get_tree().get_nodes_in_group('tilemap').front() as Map
	# get closest cell
	var map_layer = get_layer_by_name(tilemap, 'map')
	var node = inventory.node
	var cells = tilemap.get_used_cells(map_layer)
	cells.sort_custom(func(a:Vector2i,b:Vector2i): 
		return 	node.global_position.distance_to(tilemap.to_global(tilemap.map_to_local(a))) < \
				node.global_position.distance_to(tilemap.to_global(tilemap.map_to_local(b)))
	)
	var closest_cell = cells.front()
	# get/create tile_object
	var tile_object := get_tree().get_nodes_in_group('tile_object').filter(func(t:TileObject): return t.cell == closest_cell).front() as TileObject
	if not tile_object:
		tile_object = scn_tile_object.instantiate() as TileObject
		tile_object.cell = closest_cell
		tile_object.global_position = tilemap.to_global(tilemap.map_to_local(closest_cell))
		tilemap.add_child(tile_object)
		inventory.transfer_item(item_id, tile_object.inventory)
