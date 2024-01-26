extends Control

var l = Log.new(Log.LEVEL.DEBUG)

var STATION_PATH = 'res://scene/station'

@export var menu_buttons_container:Container
@export var card_list:Container

var scn_actor_card := preload("res://scene/ui/card/actor_card.tscn")
var scn_station_card := preload("res://scene/ui/card/small_card.tscn")

var stations:Array[Node] = []
var deleting = false

signal add_station(type:StationHelper.STATION_TYPE)

func enter(args:Dictionary):
	pass
	
func leave():
	pass

var _on_place_object_callback:Callable
func _on_card_pressed(event:InputEvent, object:Node2D):
	var map = TileMapHelper.get_current_map() as Map
	if not map:
		return
	map.selection_enabled = true
	map.tile_outline_color = Palette.Blue500
	if _on_place_object_callback and map.tile_select.is_connected(_on_place_object_callback):
		map.tile_select.disconnect(_on_place_object_callback)
	_on_place_object_callback = _on_place_object.bind(map, object)
	map.tile_select.connect(_on_place_object_callback)
		
func add_card(parent:Node2D, type:int):
	var objects = parent.get_children().map(func(s):return typeof(s))
	var object = parent.get_children().filter(func(s):return typeof(s) == type).front()
	if not object:
		l.warn('%s does not contain a %s scene', [parent, type])
		return
	var new_card := scn_station_card.instantiate() as SmallCard
	if 'title' in object:
		new_card.set_title(object.title)
	if 'description' in object:
		new_card.set_description(object.description)
	if 'flavor_text' in object:
		new_card.set_flavor_text(object.flavor_text)
	var icon = object.duplicate() as Station
	icon.enabled = false
	new_card.set_icon(icon)
	new_card.mouse_filter = Control.MOUSE_FILTER_STOP
	# on click
	new_card.pressed.connect(_on_card_pressed.bind(object))
	card_list.add_child(new_card)

func add_actor_card(actor_parent:Node):
	var actor := actor_parent.get_children().filter(func(s:Node):return s is Actor).front() as Actor
	if not actor:
		l.warn('%s does not contain an Actor scene', [actor_parent])
		return
	
## Returns false if nothing was cleared
func clear_cards() -> bool:
	var nothing_cleared = !card_list.get_child_count()
	for child in card_list.get_children():
		card_list.remove_child(child)
	for map in TileMapHelper.get_all_instances():
		map.selection_enabled = false
	return !nothing_cleared

func _ready():
	# Gather available stations
	var dir = DirAccess.open(STATION_PATH)
	for path in dir.get_files():
		if path.ends_with('.tscn'):
			var station = (load(STATION_PATH+'/'+path) as PackedScene).instantiate()
			stations.append(station)
	# Setup neighbors
	var menu_buttons = menu_buttons_container.get_children()
	for b in menu_buttons.size():
		var button = menu_buttons[b] as BaseButton
		if b > 0:
			button.focus_neighbor_left = (menu_buttons[b-1] as Control).get_path()
		if b+1 < menu_buttons.size():
			button.focus_neighbor_right = (menu_buttons[b+1] as Control).get_path()
			
func _on_add_actor_pressed():
	pass
	
func _on_place_object(event:InputEvent, global_position:Vector2, map_position:Vector2i, map:Map, object:Node2D):
	if map.is_tile_empty(map_position):
		var new_object := object.duplicate() as Station
		new_object.global_position = global_position
		map.add_child(new_object)

func _on_add_station_pressed():
	if clear_cards():
		return
	for station in stations:
		add_card(station, typeof(station))
	# Setup top neighbor
	var cards = card_list.get_children()
	var button = $MarginContainer/VBoxContainer/MenuButtons/AddStation
	if cards.size():
		var last_card = cards.back() as SmallCard
		# focus neighbors
		button.focus_neighbor_top = last_card.get_path()
		last_card.focus_neighbor_bottom = button.get_path()

func _on_control_gui_input(event):
	pass
	# click outside
	#if event is InputEventMouseButton:
		#clear_cards()

func _gui_input(event):
	if event.is_action_pressed('cancel'):
		clear_cards()

func _on_delete_pressed():
	var map = TileMapHelper.get_current_map() as Map
	if not map:
		return
	deleting = !deleting
	if deleting:
		clear_cards()
		map.selection_enabled = true
		map.tile_outline_color = Palette.Red500
	else:
		map.selection_enabled = false
