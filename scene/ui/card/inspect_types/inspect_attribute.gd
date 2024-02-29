class_name InspectAttribute
extends Control

var node:Node2D
var _property:String
## Node to get the property from
var property_node:Node
var args:Dictionary = {}

func update_value(value):
	pass

func is_attribute(_node:Node, attr:Variant) -> bool:
	return \
		node == _node and\
		(attr is String and _property == attr) or\
		(attr is Dictionary and _property == attr.get('property'))

func _ready():
	update_value(property_node[_property])

func _process(delta):
	update_value(property_node[_property])
