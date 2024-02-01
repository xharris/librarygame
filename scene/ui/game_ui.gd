extends Control

var l = Log.new(Log.LEVEL.DEBUG)

@onready var menu_buttons_container := $MarginContainer/VBoxContainer/MenuButtons
@onready var card_list := $MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/CardList

signal add_station(type:StationHelper.STATION_TYPE)

## Returns false if nothing was cleared
func clear_cards() -> bool:
	var nothing_cleared = !card_list.get_child_count()
	for child in card_list.get_children():
		card_list.remove_child(child)
	for map in TileMapHelper.get_all_instances():
		map.selection_enabled = false
	return !nothing_cleared
	
func _ready():
	var menu_buttons = menu_buttons_container.get_children()
	for b in menu_buttons.size():
		var button = menu_buttons[b] as BaseButton
		# connect signals
		if button is AddResourceButton:
			button.clear_cards.connect(clear_cards)
		# Setup neighbors
		if b > 0:
			button.focus_neighbor_left = (menu_buttons[b-1] as Control).get_path()
		if b+1 < menu_buttons.size():
			button.focus_neighbor_right = (menu_buttons[b+1] as Control).get_path()

func _on_remove_object(event:InputEvent, global_position:Vector2, map_position:Vector2i, map:Map):
	var stations = StationHelper.get_all()
	for station in stations:
		var station_coords = map.local_to_map(map.to_local(station.global_position))
		if station_coords == map_position:
			station.remove()

func _gui_input(event):
	if event.is_action_pressed('cancel'):
		clear_cards()

var _on_remove_object_callback:Callable
func _on_delete_pressed():
	var map = TileMapHelper.get_current_map() as Map
	if not map:
		return
	clear_cards()
	map.selection_enabled = true
	map.tile_outline_color = Palette.Red500
	if _on_remove_object_callback and map.tile_select.is_connected(_on_remove_object_callback):
		map.tile_select.disconnect(_on_remove_object_callback)
	_on_remove_object_callback = _on_remove_object.bind(map)
	map.tile_select.connect(_on_remove_object_callback)
