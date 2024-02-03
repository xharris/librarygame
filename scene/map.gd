class_name Map
extends TileMap

static var l = Log.new(Log.LEVEL.DEBUG)

enum TILE_NAME {NORMAL,EMPTY,NO_IDLE,ENTRANCE}

var inventories = {}
var nav_layer_name = 'nav'
var map_layer_name = 'map'
var selection_enabled = false
@export var initial_spawn_count = 3
@export var tile_outline:Sprite2D
var tile_outline_color:Color

signal patron_spawned(actor:Actor)
signal tile_select(event:InputEvent, global_position:Vector2, map_position:Vector2i)

func get_layer_by_name(layer_name:String) -> int:
	var layer_count = get_layers_count()
	for l in range(layer_count):
		if get_layer_name(l) == layer_name:
			return l
	return -1

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

func is_walkable(coords:Vector2i):
	if get_child_count() == 0:
		return false
	for c in get_children():
		if c is Station or c.get_children().any(func(c2:Node):return c2 is Station and c2.type != Station.STATION_TYPE.SEAT):
			var c_position = local_to_map(to_local(c.global_position))
			if c_position == coords:
				return false
	return true

func update_navigation():
	var tile_layer = TileMapHelper.get_layer_by_name(self, map_layer_name)
	var nav_layer = TileMapHelper.get_layer_by_name(self, nav_layer_name)
	if tile_layer < 0:
		return
	var tile_coords = get_used_cells(tile_layer)
	for coords in tile_coords:
		var has_nav = get_cell_source_id(nav_layer, coords) > -1
		var walkable = is_walkable(coords)
		if not has_nav and walkable:
			# add nav cell
			set_cell(nav_layer, coords, 1, Vector2i.ZERO)
		if has_nav and not walkable:
			# remove nav cell
			erase_cell(nav_layer, coords)
	
func is_tile_empty(coords:Vector2i) -> bool:
	var nav_layer = TileMapHelper.get_layer_by_name(self, nav_layer_name)
	return get_used_cells(nav_layer).any(func(c:Vector2i):return c == coords)

func get_patron_count() -> int:
	var actors = get_tree().get_nodes_in_group(Actor.GROUP)
	return actors.filter(func(a:Actor): return a.role == Actor.ACTOR_ROLE.PATRON and a.is_active()).size()

func is_max_patrons() -> bool:
	var max_capacity := (get_used_cells(TileMapHelper.get_layer_by_name(self, map_layer_name)).size() * 2/3)
	return get_patron_count() >= max_capacity

## Return [0,100] chance of spawning patron
func get_spawn_chance() -> int:
	var seat_count = get_tree().get_nodes_in_group(Station.GROUP).filter(func(s:Station):return s.type == Station.STATION_TYPE.SEAT and s.is_active()).size()
	var patron_count = get_patron_count()
	var weights = [
		(seat_count / patron_count) if patron_count > 0 else 0,
	]
	var spawn_chance = weights.reduce(func(prev,curr):return prev + curr, 0) / weights.size()
	return (spawn_chance if get_patron_count() >= initial_spawn_count else 1) * 25

func _ready():
	add_to_group('tilemap')
	update_navigation()
	tile_outline_color = Palette.Blue500

func spawn_patron():
	var entrance_tiles = get_tile_coords(TILE_NAME.ENTRANCE)
	if entrance_tiles.size():
		var actor = Actor.build(['read'])
		actor.global_position = entrance_tiles.pick_random()
		add_child(actor)
		patron_spawned.emit(actor)

func _on_patron_spawner_timeout():
	var random = randi() % 100
	var spawn_chance = get_spawn_chance()
	if not is_max_patrons() and random <= spawn_chance:
		l.debug('Spawn patron with %d%% chance (rolled %d)', [spawn_chance, random])
		spawn_patron()

func _on_child_entered_tree(node):
	update_navigation()

func _on_child_exiting_tree(node):
	update_navigation()

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
