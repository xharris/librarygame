class_name InspectPropertyHelper
extends Node2D

@export var property_node:Node2D
@export var type:InspectCard.INSPECT_TYPE:
	set(value):
		type = value
		notify_property_list_changed()
@export var property:String
@export var section:String
# text
@export var format:String = '{0}'
# progress
@export var label:String = '':
	set(value):
		label = value
		_property['label'] = value
@export var red_green:bool = true
@export var starting_value:int = 100

var _nodes:Array[Node] = []
var _property:Dictionary = {}
var _visible = false

func _validate_property(property:Dictionary):
	if property.name in ['format'] and type != InspectCard.INSPECT_TYPE.TEXT:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ['label', 'red_green', 'starting_value'] and type != InspectCard.INSPECT_TYPE.PROGRESS:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _find_inspect_card_helpers() -> Array[InspectCardRoot]:
	var helpers:Array[InspectCardRoot] = []
	var parent = get_parent()
	if parent is InspectCardRoot:
		print(parent)
		helpers.append(parent)
	return helpers

func inspect_show():
	if _visible:
		return
	# Build inspect property
	match type:
		InspectCard.INSPECT_TYPE.TEXT:
			_property = InspectText.build(property, format)
		InspectCard.INSPECT_TYPE.PROGRESS:
			_property = InspectProgress.build(property, label, red_green, starting_value)
	# Find InspectCardRoot parent
	var inspect_card_helpers = _find_inspect_card_helpers()
	if not inspect_card_helpers.size():
		return
	_nodes.assign(inspect_card_helpers.map(func(i:InspectCardRoot): return i.node))
	for node in _nodes:
		InspectCard.add_properties(node, [_property], property_node if property_node else node, section)
	_visible = true

func inspect_hide():
	if not _visible:
		return
	if _nodes.size():
		for node in _nodes:
			InspectCard.remove_properties(node, [_property])
		_visible = false

func _ready():
	inspect_show()

func _enter_tree():
	inspect_show()
	
func _exit_tree():
	inspect_hide()
