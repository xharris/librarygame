extends BTAction

@export var random_cell_key:String

func tick(actor:Node2D, data:Dictionary) -> STATUS:
	if data.has(random_cell_key):
		return success('Already set')
	var map = Map.get_current_map()
	var closest_cell = map.get_closest_cell(actor.global_position)
	# TODO avoid structures and non-idle cells
	var random_cell := map.get_random_cell(func(cell:Vector2i, map:Map):
		return cell != closest_cell) as Map.RandomTile
	if not random_cell.is_valid():
		return failure("Couldn't find random cell")
	data[random_cell_key] = random_cell.map_to_global()
	return success('%s'%[random_cell.cell])
