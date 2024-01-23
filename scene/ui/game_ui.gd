extends State

var log = Log.new(Log.LEVEL.DEBUG)

var STATION_PATH = 'res://scene/station'

@onready var menu_buttons_container := $Control/MarginContainer/VBoxContainer/MenuButtons
@onready var card_list := $Control/MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/CardList

var scn_actor_card := preload("res://scene/ui/card/actor_card.tscn")
var scn_station_card := preload("res://scene/ui/card/station_card.tscn")

var stations:Array[Node] = []

signal add_station(type:StationHelper.STATION_TYPE)

func enter(args:Dictionary):
	pass
	
func leave():
	pass

func on_station_button_pressed(type:StationHelper.STATION_TYPE):
	add_station.emit(type)

func add_station_card(station_parent:Node):
	var station := station_parent.get_children().filter(func(s:Node):return s is Station).front() as Station
	if not station:
		log.warn('%s does not contain a Station scene', [station_parent])
		return
	var new_card := scn_station_card.instantiate() as StationCard
	new_card.pressed.connect(on_station_button_pressed.bind(station))
	new_card.set_title(station.title)
	new_card.set_description(station.description)
	new_card.set_flavor_text(station.flavor_text)
	new_card.set_icon(station.duplicate())
	card_list.add_child(new_card)

## Returns false if nothing was cleared
func clear_cards() -> bool:
	var nothing_cleared = !card_list.get_child_count()
	for child in card_list.get_children():
		card_list.remove_child(child)
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

func _on_add_station_pressed():
	if clear_cards():
		return
	for station in stations:
		add_station_card(station)
	# Setup top neighbor
	var cards = card_list.get_children()
	var button = $Control/MarginContainer/VBoxContainer/MenuButtons/AddStation
	if cards.size():
		var last_card = cards.back() as StationCard
		button.focus_neighbor_top = last_card.get_path()
		last_card.focus_neighbor_bottom = button.get_path()
	
func _on_control_gui_input(event):
	pass
	# click outside
	#if event is InputEventMouseButton:
		#clear_cards()

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			clear_cards()
