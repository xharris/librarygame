class_name AStarNavigationAgent2D
extends Node2D

static var l = Log.new(Log.LEVEL.DEBUG)
static var GROUP = 'AStarNavigationAgent2D'

@export var debug_enabled:bool
var grid:AStarGrid2D
var path:Array[Vector2i] = []
var velocity:Vector2 = Vector2.ZERO
var _map:Map
var _target_position:Vector2

signal target_reached
signal blocked

func get_nearest_used_cell(coords:Vector2):
	var map_cells = _map.get_used_cells(0)
	map_cells.sort_custom(func(a:Vector2i, b:Vector2i): return _map_to_global(a).distance_to(coords) < _map_to_global(b).distance_to(coords))
	return map_cells.front()

func update_navigation():
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	var stations = StationHelper.get_all()
	var tile_layer = TileMapHelper.get_layer_by_name(_map, Map.LAYER_MAP)
	var map_cells = _map.get_used_cells(tile_layer)
	var rect = _map.get_used_rect()
	# iterate all tiles
	for x in range(grid.region.position.x, grid.region.size.x):
		for y in range(grid.region.position.y, grid.region.size.y):
			var cell = Vector2i(x, y)
			if _map.get_cell_tile_data(tile_layer, cell):
				grid.set_point_solid(cell, true)
				grid.set_point_weight_scale(cell, 1)
				l.debug('cell %s solid=%s weight=%s', [cell, true, 1])
			else:
				grid.set_point_solid(cell, false)
	# iterate stations
	for station in stations:
		var cell = get_nearest_used_cell(station.global_position)
		if not grid.is_in_bounds(cell.x, cell.y):
			continue
		var walkable = station and not station.is_solid()
		grid.set_point_solid(cell, walkable)
		var weight = 1
		if station and station.type == Station.STATION_TYPE.DOOR:
			weight = 2
		if station and station.type == Station.STATION_TYPE.SEAT:
			weight = 3
		grid.set_point_weight_scale(cell, weight)
		l.debug('cell %s solid=%s weight=%s', [cell, walkable, weight])
	l.debug('navigation updated')
	queue_redraw()

var target_position:Vector2:
	set(value):
		if _map:
			_target_position = value
			var current_cell = get_nearest_used_cell(global_position)
			var target = get_nearest_used_cell(value)
			path = grid.get_id_path(current_cell, target)
			queue_redraw()
			l.debug('target_position %s -> %s path=%s', [current_cell, target, path])
	get:
		return _target_position

func is_pathing() -> bool:
	return not path.is_empty()

func _map_to_global(coords:Vector2i) -> Vector2:
	if not _map:
		return Vector2.ZERO
	return _map.to_global(_map.map_to_local(coords))

func get_next_position() -> Vector2:
	if path.is_empty():
		return global_position
	return _map_to_global(path.front())

func stop():
	velocity = Vector2.ZERO
	path = []

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GROUP)
	grid = AStarGrid2D.new()
	_get_map()

func _get_map():
	_map = TileMapHelper.get_current_map()
	# connect new map
	_map.child_entered_tree.connect(_map_tree_changed)
	_map.child_exiting_tree.connect(_map_tree_changed)
	grid.region = _map.get_used_rect()
	grid.cell_size = _map.tile_set.tile_size
	grid.update()
	update_navigation()

func _map_tree_changed(node:Node):
	update_navigation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not _map:
		return
	if path.is_empty():
		return stop()
	var target_position = get_next_position()
	if target_position == global_position:
		# reached next point
		path.pop_front()
		target_position = get_next_position()
	if path.is_empty():
		# navigation finished
		target_reached.emit()
		return
	## TODO try this vvv
	#if not _map.get_used_cells(Map.LAYER_MAP).has(_map.local_to_map(_map.to_local(target_position))):
		## navigation blocked
		#blocked.emit()
		#return
	#velocity = global_position.move_toward(target_position, 1)

func _draw():
	if debug_enabled and _map:
		var inverse = global_transform.inverse()
		draw_set_transform(inverse.get_origin(), inverse.get_rotation(), inverse.get_scale())
		var rect = Rect2(_map_to_global(grid.region.position), _map_to_global(grid.region.size))
		if path.size():
			path.assign(path.map(func(p:Vector2i):return _map_to_global(p)) as Array[Vector2])
			draw_polyline(path, Color.BLUE)
		for x in grid.region.size.x:
			for y in grid.region.size.y:
				var cell = Vector2i(x + grid.region.position.x, y + grid.region.position.y)
				if grid.is_point_solid(cell):
					var color = Color.LIGHT_GREEN.lerp(Color.DARK_GREEN, grid.get_point_weight_scale(cell) / 2)
					draw_rect(Rect2(_map_to_global(cell) - Vector2(2, 2), Vector2(4, 4)), color)
