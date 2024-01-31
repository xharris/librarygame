class_name AddResourceButton
extends Control

var scn_small_card := preload("res://scene/ui/card/small_card.tscn")
var _scenes:Array[Node]
var _card_list:Array[SmallCard]
@export var resource_path:String
var selected_resource:Node
@export var card_container:Container

signal clear_cards

func _on_place_object(event:InputEvent, global_position:Vector2, map_position:Vector2i, map:Map, object:Node2D):
	if map.is_tile_empty(map_position):
		var new_object := object.duplicate()
		new_object.global_position = global_position
		map.add_child(new_object)

func _on_card_pressed(event:InputEvent, object:Node2D):
	clear_cards.emit()
	selected_resource = object
	var map = TileMapHelper.get_current_map() as Map
	if not map:
		return
	map.selection_enabled = true
	map.tile_outline_color = Palette.Blue500
	map.tile_select.connect(_on_place_object.bind(map, object))

func get_resources(value:String = resource_path):
	# Gather available scenes
	var scene_dir = DirAccess.open(resource_path)
	for path in scene_dir.get_files():
		if path.ends_with('.tscn'):
			var scene = (load(resource_path+'/'+path) as PackedScene).instantiate()
			_scenes.append(scene)
	# Turn them into cards
	_card_list = []
	for scene in _scenes:
		var new_card := scn_small_card.instantiate() as SmallCard
		new_card.config(scene)
		new_card.pressed.connect(_on_card_pressed.bind(scene))
		_card_list.append(new_card)

func _on_pressed():
	clear_cards.emit()
	for card in _card_list:
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
