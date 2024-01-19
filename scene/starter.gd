extends TileMap

func is_structure_at(coords:Vector2i):
	if get_child_count() == 0:
		return false
	for c in get_children():
		if c.is_in_group('structure') and c.is_class('Node2D'):
			var c_position = local_to_map(to_local((c as Node2D).global_position))
			if c_position == coords:
				return true
	return false
	
func update_navigation():
	var tile_layer = TileMapHelper.get_layer_by_name(self, 'map')
	var nav_layer = TileMapHelper.get_layer_by_name(self, 'nav')
	if tile_layer < 0:
		return
	var tile_coords = get_used_cells(tile_layer)
	for coords in tile_coords:
		var has_nav = get_cell_source_id(nav_layer, coords) > -1
		var has_structure = is_structure_at(coords)
		if not has_nav and not has_structure:
			# add nav cell
			set_cell(nav_layer, coords, 1, Vector2i.ZERO)
		if has_nav and has_structure:
			# remove nav cell
			erase_cell(nav_layer, coords)

func _enter_tree():
	add_to_group('tilemap')
	
func _ready():
	update_navigation()

func _on_nav_mesh_timer_timeout():
	update_navigation()
