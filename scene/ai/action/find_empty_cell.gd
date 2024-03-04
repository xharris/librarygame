extends ActionLeaf

@export var position_key:String

func tick(actor, blackboard: Blackboard):
	var map = Map.get_current_map()
	if not map:
		return FAILURE
	var empty_cells = map.get_used_cells(0).filter(map.filter_is_cell_empty)
	if not empty_cells.size():
		return FAILURE
	blackboard.set_value(position_key, map.map_to_global(empty_cells.front()))
	return SUCCESS

