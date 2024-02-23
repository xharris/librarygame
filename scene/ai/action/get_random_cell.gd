extends ActionLeaf

@export var random_cell_key:String
@export var avoid_stations:bool = true
@export var is_tile_name:Map.TILE_NAME = Map.TILE_NAME.NORMAL

func tick(actor, blackboard: Blackboard):
	var map = Map.get_current_map()
	var closest_cell = map.get_closest_cell(actor.global_position)
	# find random cell, avoiding structures and non-idle cells
	var stations = Station.get_all()
	var random_cell := map.get_random_cell(func(cell:Vector2i, map:Map):
		return cell != closest_cell &&\
			(!avoid_stations || !stations.any(func(s:Station):return s.map_cell == cell)) &&\
			map.get_tile_name(cell) == is_tile_name
		) as Map.RandomTile
	if not random_cell.is_valid():
		return FAILURE
	blackboard.set_value(random_cell_key, random_cell.map_to_global())
	return SUCCESS

