extends Node

func get_layer_by_name(tilemap:TileMap, layer_name:String):
	var layer_count = tilemap.get_layers_count()
	for l in range(layer_count):
		if tilemap.get_layer_name(l) == layer_name:
			return l
	return -1

class RandomTile:
	var tilemap: TileMap
	var cell: Vector2i
	func is_valid():
		return tilemap != null && cell != null
	func map_to_global():
		return tilemap.to_global(tilemap.map_to_local(cell))

func get_random_tilemap_cell(filter: Callable = Callable()) -> RandomTile:
	var tilemap:TileMap = get_tree().get_nodes_in_group('tilemap').pick_random()
	var rand_tile = RandomTile.new()
	if tilemap:
		var map_layer = get_layer_by_name(tilemap, 'map')
		rand_tile.tilemap = tilemap
		var cells = tilemap.get_used_cells(map_layer)
		if filter.is_valid():
			cells = cells.filter(filter)
		rand_tile.cell = cells.pick_random()
	return rand_tile
