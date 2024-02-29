class_name AStarNavigationAgent2D
extends Node2D

static var l = Log.new()#Log.LEVEL.DEBUG)
static var GROUP = 'AStarNavigationAgent2D'
enum STOP_TYPE {REACHED,BLOCKED,INTERRUPT}

@export var debug_enabled:bool
@export var agent:Node2D
@export var target_desired_distance:int = 1
var grid:AStar2D
var path:Array[int] = []
var velocity:Vector2 = Vector2.ZERO
var _map:Map
var _target_position:Vector2 = Vector2.INF
var _needs_update = false
var _done = true
var weight_colors = [Color.GREEN, Color.YELLOW, Color.RED]
var _point_ids:Dictionary

signal target_reached
signal blocked

func _get_point_id(cell:Vector2i):
	#if _point_ids.has(cell):
		#return _point_ids.get(cell) as int
	#_point_ids[cell] = grid.get_available_point_id()
	#return _point_ids[cell]
	
	var rect = _map.get_used_rect()
	return (cell.x - rect.position.x) + rect.size.x * (cell.y - rect.position.y) # int((cell.y - rect.position.y) + (cell.x - rect.position.x) * rect.size.y)
	
func _update_navigation():
	var stations = StationHelper.get_all()
	var map_cells = _map.get_used_cells(0)
	var rect = _map.get_used_rect()
	grid.reserve_space(rect.size.x * rect.size.y)
	grid.clear()
	_point_ids = {}
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
				TileSet.CELL_NEIGHBOR_LEFT_CORNER,
				#TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
				TileSet.CELL_NEIGHBOR_RIGHT_CORNER,
				TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
				#TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
				#TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
				TileSet.CELL_NEIGHBOR_BOTTOM_CORNER,
				TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
				#TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
				TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
				#TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
				#TileSet.CELL_NEIGHBOR_TOP_SIDE,
				TileSet.CELL_NEIGHBOR_TOP_CORNER,
				TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
				#TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER
			]
			for n in cell_neighbor:
				var neighbor = _map.get_neighbor_cell(cell, n)
				if not neighbor:
					continue
				var point_id = _get_point_id(neighbor)
				if grid.has_point(point_id) and not grid.is_point_disabled(point_id):
					neighbor_ids.append(point_id)
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
	# iterate map tiles with items on it
	for map_tile in MapTile.get_all():
		var id = grid.get_closest_point(map_tile.global_position)
		if map_tile.inventory.size():
			grid.set_point_disabled(id, true)
	l.debug('navigation updated')
	queue_redraw()

func _get_closest_empty_point(target:Vector2) -> int:
	var id = grid.get_closest_point(target)
	var cell = grid.get_point_position(id)
	var points = Array(grid.get_point_ids())
	# avoid stations
	var stations = StationHelper.get_all()
	points = points.filter(func(p:int):
		return not stations.any(func(s:Station): return grid.get_closest_point(s.global_position) == p))
	# sort distance
	points.sort_custom(func(a:int,b:int):
		var a_pos = grid.get_point_position(a)
		var b_pos = grid.get_point_position(b)
		return cell.distance_to(a_pos) < cell.distance_to(b_pos))
	if points.size():
		return points.front()
	return -1

func _update_path():
	var previous_path_size = path.size()
	var from_id = grid.get_closest_point(agent.global_position)
	var to_id = grid.get_closest_point(_target_position)
	path.assign(grid.get_id_path(from_id, to_id))
	if (from_id == to_id or path.size() < 1) and not _done:
		stop(STOP_TYPE.REACHED)
		return
	if path.size() < 1 and previous_path_size > 1:
		stop(STOP_TYPE.BLOCKED)
		return
	_done = false
	l.debug('target_position %s %s -> %s %s path=%s', 
		[from_id, grid.get_point_position(from_id), to_id, grid.get_point_position(to_id), path])
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
	if not path.size():
		return agent.global_position
	return grid.get_point_position(path.front())
	
func stop(type:STOP_TYPE = STOP_TYPE.INTERRUPT):
	velocity = Vector2.ZERO
	path = []
	_target_position = agent.global_position
	if not _done:
		l.debug('%s stop %s',[agent, STOP_TYPE.find_key(type)])
		match type:
			STOP_TYPE.REACHED:
				target_reached.emit()
			STOP_TYPE.BLOCKED:
				blocked.emit()
			STOP_TYPE.INTERRUPT:
				target_reached.emit()
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
	if node.find_child('Station') or node is MapTile:
		update()

func _process(delta):
	if _needs_update:
		_needs_update = false
		_update_navigation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not _map:
		return
	var target_position = get_next_position()
	if target_position.distance_to(agent.global_position) <= target_desired_distance:
		# navigation finished
		if path.size() <= 0 and not _done:
			stop(STOP_TYPE.REACHED)
			return
		# reached next point
		if path.size() > 0:
			_update_path()
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
