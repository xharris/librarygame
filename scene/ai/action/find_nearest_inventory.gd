extends ActionLeaf

static var scn_map_tile = preload('res://scene/map_tile.tscn')

@export var is_not_full:bool = true
@export var is_actor_inventory:bool = false
@export var inventory_key:String
@export var can_create_map_tile:bool = true

func inventory_filter(i:Inventory, actor_inventory:Inventory, is_map_tile:bool):
	if not is_map_tile and i.parent is MapTile:
		return false
	if actor_inventory == i:
		return false
	if is_not_full and i.is_full():
		return false
	if not is_actor_inventory and i.parent is Actor:
		return false
	return true

func tick(actor, blackboard: Blackboard):
	var actor_inventory := actor.inventory as Inventory
	var inventories = Inventory.get_all()
	var filtered_inventories = inventories.filter(inventory_filter.bind(actor_inventory, false))
	# try map tile inventories
	if not filtered_inventories.size():
		filtered_inventories = inventories.filter(inventory_filter.bind(actor_inventory, true))
	if filtered_inventories.size():
		# get nearest inventory
		Global.sort_distance(actor, filtered_inventories)
		blackboard.set_value(inventory_key, filtered_inventories.front())
		return SUCCESS
	if can_create_map_tile:
		# spawn inventory on map floor
		actor = actor as Node2D
		if not actor:
			return FAILURE
		var map_tile = scn_map_tile.instantiate() as MapTile
		var map := TileMapHelper.get_current_map() as Map
		var cells = map.get_used_cells(0).filter(map.filter_is_cell_empty)
		Global.sort_distance_vector2i(map.global_to_map(actor.global_position), cells)
		if not cells.size():
			return FAILURE
		map_tile.cell = cells.front() as Vector2i
		map.add_child(map_tile)
		blackboard.set_value(inventory_key, map_tile.inventory)
		return SUCCESS
	blackboard.erase_value(inventory_key)
	return FAILURE
