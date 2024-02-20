extends ActionLeaf

@export var random_cell_key:String

func tick(actor, blackboard: Blackboard):
	var map = Map.get_current_map()
	var closest_cell = map.get_closest_cell(actor.global_position)
	# TODO avoid structures and non-idle cells
	var random_cell := map.get_random_cell(func(cell:Vector2i, map:Map):
		return cell != closest_cell) as Map.RandomTile
	if not random_cell.is_valid():
		return FAILURE
	blackboard.set_value(random_cell_key, random_cell.map_to_global())
	return SUCCESS

