class_name Map
extends TileMap

var scn_patron = preload("res://scene/patron.tscn")
var inventories = {}
var nav_layer_name = 'nav'
## increases when average happiness increases
var spawn_chance = 0 # / 100 
@export var initial_spawn_count = 3

signal spawn_patron(actor:Actor)

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
		if c is Station:
			var c_position = local_to_map(to_local(c.global_position))
			if c_position == coords:
				return false
	return true

func update_navigation():
	var tile_layer = TileMapHelper.get_layer_by_name(self, 'map')
	var nav_layer = TileMapHelper.get_layer_by_name(self, nav_layer_name)
	if tile_layer < 0:
		return
	var tile_coords = get_used_cells(tile_layer)
	for coords in tile_coords:
		var has_nav = get_cell_source_id(nav_layer, coords) > -1
		var is_walkable = is_walkable(coords)
		if not has_nav and is_walkable:
			# add nav cell
			set_cell(nav_layer, coords, 1, Vector2i.ZERO)
		if has_nav and not is_walkable:
			# remove nav cell
			erase_cell(nav_layer, coords)

func _enter_tree():
	add_to_group('tilemap')
	
func _ready():
	update_navigation()

func _on_patron_spawner_timeout():
	var entrance_tiles = get_tile_coords('entrance')
	var patron_count := get_tree().get_nodes_in_group('actor').filter(func(a:Actor): return a.role == ActorHelper.ACTOR_ROLE.PATRON).size()
	var map_capacity := (get_used_cells(TileMapHelper.get_layer_by_name(self, 'map')).size() * 2/3)
	if entrance_tiles.size() and patron_count < map_capacity and (randi() % 100) < (spawn_chance if patron_count >= initial_spawn_count else 60):
		var new_patron := scn_patron.instantiate()
		new_patron.global_position = entrance_tiles.pick_random()
		spawn_patron.emit(new_patron.find_child('Actor'))
		add_child(new_patron)

func _on_child_entered_tree(node):
	update_navigation()

func _on_child_exiting_tree(node):
	update_navigation()
