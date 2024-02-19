class_name AStarNavigationAgent2D
extends Node2D

static var l = Log.new()
static var GROUP = 'AStarNavigationAgent2D'

@export var debug_enabled:bool
@export var agent:Node2D
@export var target_desired_distance:int = 1
var grid:AStar2D
var path:Array[int] = []
var velocity:Vector2 = Vector2.ZERO
var _map:Map
var _target_position:Vector2
var _needs_update = false
var _done = true
var weight_colors = [Color.GREEN, Color.YELLOW, Color.RED]

signal target_reached
signal blocked

func _get_point_id(cell:Vector2i):
	var rect = _map.get_used_rect()
	return (cell.x - rect.position.x) + rect.size.x * (cell.y - rect.position.y) # int((cell.y - rect.position.y) + (cell.x - rect.position.x) * rect.size.y)
	
func _update_navigation():
	var stations = StationHelper.get_all()
	var map_cells = _map.get_used_cells(0)
	var rect = _map.get_used_rect()
	grid.reserve_space(rect.size.x * rect.size.y)
	grid.clear()
	# iterate all tiles
	for x in rect.size.x:
		for y in rect.size.y:
			var cell = Vector2i(x + rect.position.x, y + rect.position.y)
			var id = _get_point_id(cell)
			if map_cells.has(cell):
				grid.add_point(id, _map.map_to_global(cell), 0)
				grid.set_point_disabled(id, false)
				#l.debug('add point %s %s position=%s', [id, cell, _map.map_to_global(cell)])
	# connect neighbors
	for x in rect.size.x:
		for y in rect.size.y:
			var cell = Vector2i(x + rect.position.x, y + rect.position.y)
			var id = _get_point_id(cell)
			if not map_cells.has(cell):
				continue
			var neighbor_ids:Array[int] = []
			var cell_neighbor = [
				TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
				TileSet.CELL_NEIGHBOR_RIGHT_CORNER,
				TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
				TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
				TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
				TileSet.CELL_NEIGHBOR_BOTTOM_CORNER,
				TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
				TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
				TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
				TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
				TileSet.CELL_NEIGHBOR_TOP_SIDE,
				TileSet.CELL_NEIGHBOR_TOP_CORNER,
				TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
				TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER
			]
			neighbor_ids.assign(
				cell_neighbor.\
				map(func(n:int):return _map.get_neighbor_cell(cell, n)).\
				map(_get_point_id).\
				filter(func(n:int):return grid.has_point(n) and not grid.is_point_disabled(n))
			)
			#l.debug('connect %d -> %s', [id, neighbor_ids])
			for neighbor_id in neighbor_ids:
				if id != neighbor_id:
					grid.connect_points(id, neighbor_id)
	# iterate stations
	for station in stations:
		var id = grid.get_closest_point(station.global_position)
		if not grid.has_point(id) or not station.is_active():
			continue
		var weight = 0
		var cell_data = _map.get_cell_tile_data(0, station.map_cell)
		match station.type:
			Station.STATION_TYPE.DOOR:
				weight = 1
			Station.STATION_TYPE.SEAT:
				weight = 2
			Station.STATION_TYPE.STORAGE:
				grid.set_point_disabled(id, true)
		grid.set_point_weight_scale(id, weight)
		#l.debug('cell %s station=%s disabled=%s weight=%s', [id, station, not walkable, weight])
	l.debug('navigation updated')
	queue_redraw()

func _update_path():
	var previous_path_size = path.size()
	var from_id = grid.get_closest_point(agent.global_position)
	var to_id = grid.get_closest_point(_target_position)
	if from_id == to_id and not _done:
		l.info('%s target reached (no movement)', [agent])
		stop()
		target_reached.emit()
		return
	path.assign(grid.get_id_path(from_id, to_id))
	if path.size() == 0 and previous_path_size > 0:
		l.info('%s blocked', [agent])
		blocked.emit()
	_done = false
	l.debug('target_position %s -> %s path=%s', [from_id, to_id, path])
	queue_redraw()

var target_position:Vector2:
	set(value):
		if _map and value != _target_position:
			_target_position = value
			_update_path()
	get:
		return _target_position

func is_pathing() -> bool:
	return path.size() > 0

func get_next_position() -> Vector2:
	if not is_pathing():
		return agent.global_position
	return grid.get_point_position(path.front())
	
func stop():
	velocity = Vector2.ZERO
	path = []
	_target_position = agent.global_position
	_done = true

func update():
	_needs_update = true

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GROUP)
	grid = AStar2D.new()
	_get_map()
	_update_navigation()

func _get_map():
	_map = TileMapHelper.get_current_map() as Map
	# connect new map
	_map.child_entered_tree.connect(_map_tree_changed)
	_map.child_exiting_tree.connect(_map_tree_changed)

func _map_tree_changed(node:Node):
	update()

func _process(delta):
	if _needs_update:
		_needs_update = false
		_update_navigation()
		_update_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not _map:
		return
	var target_position = get_next_position()
	if target_position.distance_to(agent.global_position) <= target_desired_distance:
		# reached next point
		if not is_pathing() and not _done:
			# navigation finished
			l.info('%s target reached', [agent])
			stop()
			target_reached.emit()
			return
		else:
			path.pop_front()
			target_position = get_next_position()
	velocity = agent.global_position.direction_to(target_position)

func _draw():
	if debug_enabled and _map:
		#var inverse = global_transform.inverse()
		#draw_set_transform(inverse.get_origin(), inverse.get_rotation(), inverse.get_scale())
		var map_rect = _map.get_used_rect()
		var rect = Rect2(_map.map_to_global(map_rect.position), _map.map_to_global(map_rect.size))
		var tile_size = Vector2(8, 8) # _map.map_to_global(_map.tile_set.tile_size) / 2
		for id in grid.get_point_ids():
			var _position = grid.get_point_position(id)
			var color = Color.DIM_GRAY
			if not grid.is_point_disabled(id):
				color = weight_colors[grid.get_point_weight_scale(id)] # Color.LIGHT_GREEN.lerp(Color.DARK_GREEN, grid.get_point_weight_scale(id) / 2)
			draw_rect(Rect2(_position - tile_size/2, tile_size), color, false)
			color.a = 0.2
			draw_rect(Rect2(_position - tile_size/2, tile_size), color)
			# neighbors
			for neighbor in grid.get_point_connections(id):
				var neighbor_position = grid.get_point_position(neighbor)
				color = Color.LIGHT_GREEN
				color.a = 0.2
				draw_line(_position, neighbor_position, color, 1)
		# draw path
		if path.size():
			var point_path:Array[Vector2] = []
			for id in path:
				point_path.append(grid.get_point_position(id))
			draw_polyline(point_path, Color.BLUE, 1)
