extends ActionLeaf

static var scn_map_tile = preload('res://scene/map_tile.tscn')
@export var inventory_key:String

func tick(actor, blackboard: Blackboard):
	actor = actor as Node2D
	if not actor:
		return FAILURE
	var map := TileMapHelper.get_current_map() as Map
	if not map:
		return FAILURE
	var node_cell = map.get_closest_cell(actor.global_position, Map.TILE_NAME.NORMAL)
	# Get MapTile at node (if it exists)
	var map_tiles = get_tree().get_nodes_in_group(MapTile.GROUP).filter(func(m:MapTile):return m.cell == node_cell)
	var map_tile:MapTile
	if map_tiles.size():
		map_tile = map_tiles.front()
	if not map_tile:
		# Create a new map tile under the node
		map_tile = scn_map_tile.instantiate() as MapTile
		map_tile.cell = node_cell
		map_tile.global_position = map.to_global(map.map_to_local(node_cell))
		map.add_child(map_tile)
	if inventory_key.length():
		blackboard.set_value(inventory_key, map_tile.inventory)
	return SUCCESS
