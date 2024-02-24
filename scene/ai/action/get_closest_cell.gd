extends ActionLeaf

@export var position_key:String
@export var tile_name:Map.TILE_NAME = Map.TILE_NAME.NORMAL

func tick(actor, blackboard: Blackboard):
	var map := TileMapHelper.get_current_map() as Map
	var closest_cell = map.get_closest_cell(actor.global_position, tile_name)
	if not closest_cell or not closest_cell:
		return FAILURE
	blackboard.set_value(position_key, map.map_to_global(closest_cell))
	return SUCCESS

