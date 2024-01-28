class_name Map
extends TileMap

var scn_patron = preload("res://scene/actors/patron.tscn")
var inventories = {}
var nav_layer_name = 'nav'
var map_layer_name = 'map'
## increases when average happiness increases
var spawn_chance = 0 # / 100 
var selection_enabled = false
@export var initial_spawn_count = 3
@export var tile_outline:Sprite2D
var tile_outline_color:Color

signal spawn_patron(actor:Actor)
signal tile_select(event:InputEvent, global_position:Vector2, map_position:Vector2i)

func get_layer_by_name(layer_name:String) -> int:
	var layer_count = get_layers_count()
	for l in range(layer_count):
		if get_layer_name(l) == layer_name:
			return l
	return -1

func get_tile_coords(tile_name:String):
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
		if c is Station or c.get_children().any(func(c2:Node):return c2 is Station):
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
	
func _ready():
	add_to_group('tilemap')
	update_navigation()
	tile_outline_color = Palette.Blue500

func _on_patron_spawner_timeout():
	var entrance_tiles = get_tile_coords('entrance')
	var patron_count := get_tree().get_nodes_in_group('actor').filter(func(a:Actor): return a.role == Actor.ACTOR_ROLE.PATRON).size()
	var map_capacity := (get_used_cells(TileMapHelper.get_layer_by_name(self, map_layer_name)).size() * 2/3)
	if entrance_tiles.size() and patron_count < map_capacity and (randi() % 100) < (spawn_chance if patron_count >= initial_spawn_count else 60):
		var new_patron := scn_patron.instantiate()
		new_patron.global_position = entrance_tiles.pick_random()
		add_child(new_patron)
		var actor = new_patron.find_child('Actor') as Actor
		spawn_patron.emit(actor)

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
