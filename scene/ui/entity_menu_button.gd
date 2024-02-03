class_name EntityMenuButton
extends Control

static var l = Log.new()

var scn_small_card := preload("res://scene/ui/card/small_card.tscn")
var _scenes:Array[PackedScene]
var _card_list:Array[SmallCard]
@export var resource_path:String
var selected_resource:SmallCard
@export var card_container:Container
@export var place_at_entrance:bool

signal clear_cards
		
func _on_place_object(event:InputEvent, global_position:Vector2, map_position:Vector2i, map:Map, object:PackedScene):
	if map.is_tile_empty(map_position):
		var new_object := object.instantiate()
		new_object.global_position = global_position
		map.add_child(new_object)

var _last_place_object:Callable
func _on_card_pressed(event:InputEvent, card:SmallCard):
	var map = TileMapHelper.get_current_map() as Map
	if not map:
		return
	if card.scene_type == SmallCard.SCENE_TYPE.ACTOR:
		# place entity at entrance (actor)
		map.selection_enabled = false
		var entrances = map.get_tile_coords(Map.TILE_NAME.ENTRANCE)
		if not entrances.size():
			l.warn('No entrances found to spawn actor')
			return
		var new_object := card.scene.instantiate()
		new_object.global_position = entrances.front()
		map.add_child(new_object)
	else:
		# allow user to place entity on map
		map.selection_enabled = true
		map.tile_outline_color = Palette.Blue500
		selected_resource = card
		if _last_place_object:
			map.tile_select.disconnect(_last_place_object)
		_last_place_object = _on_place_object.bind(map, card.scene)
		map.tile_select.connect(_last_place_object)

func get_resources(value:String = resource_path):
	# Gather available scenes
	var scene_dir = DirAccess.open(resource_path)
	for path in scene_dir.get_files():
		if path.ends_with('.tscn'):
			var scene = load(resource_path+'/'+path)
			_scenes.append(scene)
	# Turn them into cards
	_card_list = []
	for scene in _scenes:
		var new_card := scn_small_card.instantiate() as SmallCard
		new_card.scene = scene
		new_card.pressed.connect(_on_card_pressed.bind(new_card))
		_card_list.append(new_card)

func _on_pressed():
	clear_cards.emit()
	for card in _card_list:
		var parent = card.get_parent()
		if parent:
			parent.remove_child(card)
		card_container.add_child(card)
	# Setup top neighbor
	var cards = card_container.get_children()
	if cards.size():
		var last_card = cards.back() as SmallCard
		# focus neighbors
		focus_neighbor_top = last_card.get_path()
		last_card.focus_neighbor_bottom = get_path()

func _ready():
	get_resources()
