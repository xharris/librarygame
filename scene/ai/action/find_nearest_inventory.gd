extends ActionLeaf

static var scn_map_tile = preload('res://scene/map_tile.tscn')

@export var is_empty:bool = true
@export var is_actor_inventory:bool = false
@export var inventory_key:String
@export var can_create_map_tile:bool = true

func inventory_filter(i:Inventory, actor_inventory:Inventory):
	if actor_inventory == i:
		return false
	if is_empty and i.is_full():
		return false
	if not is_actor_inventory and i.parent is Actor:
		return false
	return true

func tick(actor, blackboard: Blackboard):
	var actor_inventory := actor.inventory as Inventory
	var inventories = Inventory.get_all()
	if is_empty:
		inventories = inventories.filter(inventory_filter.bind(actor_inventory))
	if inventories.size():
		# get nearest inventory
		Global.sort_distance(actor, inventories)
		blackboard.set_value(inventory_key, inventories.front())
		return SUCCESS
	if can_create_map_tile:
		# spawn inventory on map floor
		actor = actor as Node2D
		if not actor:
			return FAILURE
		var map_tile = scn_map_tile.instantiate() as MapTile
		var map := TileMapHelper.get_current_map() as Map
		map_tile.cell = map.get_closest_cell(actor.global_position, Map.TILE_NAME.NORMAL)
		map.add_child(map_tile)
		blackboard.set_value(inventory_key, map_tile.inventory)
		return SUCCESS
	return FAILURE
