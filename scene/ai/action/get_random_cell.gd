extends BTAction

@export var random_cell_key:String

func tick(actor:Node, data:Dictionary) -> STATUS:
	if data.has(random_cell_key):
		return STATUS.SUCCESS
	var map = Map.get_current_map()
	# TODO avoid structures and non-idle cells
	var random_cell := map.get_random_cell() as Map.RandomTile
	if not random_cell.is_valid():
		return STATUS.FAILURE
	data[random_cell_key] = random_cell.map_to_global()
	return STATUS.SUCCESS
