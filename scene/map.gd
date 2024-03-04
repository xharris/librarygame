class_name Map
extends TileMap

static var l = Log.new()
static var GROUP = 'map'
static var LAYER_MAP = 'map'

enum TILE_NAME {NORMAL,EMPTY,NO_IDLE,ENTRANCE,NONE}

static func get_current_map() -> Map:
	return Global.get_tree().get_nodes_in_group(GROUP).front() as Map

class RandomTile:
	var tilemap: Map
	var cell: Vector2i
	func is_valid():
		return tilemap != null && cell != null
	func map_to_global() -> Vector2:
		return tilemap.to_global(tilemap.map_to_local(cell))

var inventories = {}
var nav_layer_name = 'nav'
var map_layer_name = 'map'
var selection_enabled = false
@export var tile_outline:Sprite2D
var tile_outline_color:Color

signal actor_spawned(actor:Actor)
signal tile_select(event:InputEvent, global_position:Vector2, map_position:Vector2i)

func get_random_cell(filter: Callable = Callable()) -> RandomTile:
	var rand_tile = RandomTile.new()
	rand_tile.tilemap = self
	var cells = get_used_cells(0)
	if filter.is_valid():
		cells = cells.filter(filter.bind(self))
	if cells.size():
		rand_tile.cell = cells.pick_random()
	return rand_tile

func is_tile_empty(coords:Vector2i) -> bool:
	var nav_layer = TileMapHelper.get_layer_by_name(self, nav_layer_name)
	return get_used_cells(nav_layer).any(func(c:Vector2i):return c == coords)

func filter_is_cell_empty(c:Vector2i) -> bool:
	if get_tile_name(c) != Map.TILE_NAME.NORMAL:
		return false
	for station in Station.get_all():
		if station.map_cell == c:
			return false
	for actor in Actor.get_all():
		if actor.is_sitting() and global_to_map(actor.global_position) == c:
			return false
	for map_tile in MapTile.get_all():
		if map_tile.cell == c and map_tile.inventory.size() > 0:
			return false
	return true

func get_layer_by_name(layer_name:String) -> int:
	var layer_count = get_layers_count()
	for l in range(layer_count):
		if get_layer_name(l) == layer_name:
			return l
	return -1

func get_tile_name(cell:Vector2i) -> TILE_NAME:
	var src := tile_set.get_source(get_cell_source_id(0, cell))
	if not src:
		return TILE_NAME.NONE
	return TILE_NAME.get(src.resource_name.to_upper())
	
func get_tile_coords(_tile_name:TILE_NAME) -> Array[Vector2]:
	var tile_name = (TILE_NAME.find_key(_tile_name) as String).to_lower()
	var layers = get_layers_count()
	var tiles:Array[Vector2] = []
	for l in layers:
		if get_layer_name(l) == nav_layer_name:
			continue
		var cells = get_used_cells(l)
		for cell in cells:
			var tile_data := get_cell_tile_data(l, cell)
			var src := tile_set.get_source(get_cell_source_id(l, cell))
			if src.resource_name == tile_name:
				tiles.append(to_global(map_to_local(cell)))
	return tiles

func global_to_map(coords:Vector2) -> Vector2i:
	return local_to_map(to_local(coords))

func map_to_global(coords:Vector2i) -> Vector2:
	return to_global(map_to_local(coords))

func _ready():
	tile_outline_color = Palette.Blue500

func spawn_actor(actor:Actor):
	var entrance_tiles = get_tile_coords(TILE_NAME.ENTRANCE)
	if entrance_tiles.size():
		actor.global_position = entrance_tiles.pick_random()
		add_child(actor)
		actor_spawned.emit(actor)

func get_closest_cell(coords:Vector2, name_filter:TILE_NAME = TILE_NAME.NONE) -> Vector2i:
	var used_cells = get_used_cells(0).filter(func(cell:Vector2):
		return name_filter == TILE_NAME.NONE or get_tile_name(cell) == name_filter)
	used_cells.sort_custom(func(a:Vector2i, b:Vector2i):
		return to_global(map_to_local(a)).distance_to(coords) < to_global(map_to_local(b)).distance_to(coords))
	return used_cells.front()

func _unhandled_input(event):
	var mouse_position = get_viewport().get_camera_2d().get_global_mouse_position()
	var tile_coords = local_to_map(to_local(mouse_position))
	if selection_enabled and get_cell_tile_data(TileMapHelper.get_layer_by_name(self, map_layer_name), tile_coords):
		tile_outline.visible = true
		var tile_global_position = to_global(map_to_local(tile_coords))
		# move tile selection outline
		if event is InputEventMouseMotion:
			tile_outline.position = tile_global_position
		# click (tile selection)
		if event.is_action_pressed('select'):
			tile_select.emit(event, tile_global_position, tile_coords)
	else:
		tile_outline.visible = false

func _process(delta):
	if not selection_enabled:
		tile_outline.visible = false
	tile_outline.modulate = tile_outline.modulate.lerp(tile_outline_color, delta * 5)
