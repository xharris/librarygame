extends Button

func _on_remove_object(event:InputEvent, global_position:Vector2, map_position:Vector2i, map:Map):
	var stations = StationHelper.get_all()
	for station in stations:
		if station.is_active() and station.map_cell == map_position:
			station.remove()

var _on_remove_object_callback:Callable
func _on_pressed():
	var map = TileMapHelper.get_current_map() as Map
	if not map:
		return
	map.selection_enabled = true
	map.tile_outline_color = Palette.Red500
	if _on_remove_object_callback and map.tile_select.is_connected(_on_remove_object_callback):
		map.tile_select.disconnect(_on_remove_object_callback)
	_on_remove_object_callback = _on_remove_object.bind(map)
	map.tile_select.connect(_on_remove_object_callback)
