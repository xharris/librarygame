class_name InspectCard
extends PanelContainer

static var l = Log.new()
static var GROUP = 'inspect_card'
enum INSPECT_TYPE {TEXT, PROGRESS}
static var scenes = {
	INSPECT_TYPE.TEXT: preload('res://scene/ui/card/inspect_attribute/text.tscn'),
	INSPECT_TYPE.PROGRESS: preload('res://scene/ui/card/inspect_attribute/progress.tscn')
}
static var scn_inspect_card = preload('res://scene/ui/card/inspect_card.tscn')
static var _inspect_cards = {}

static func get_existing(node:Node) -> InspectCard:
	var card = _inspect_cards.get(node) as InspectCard
	if not card:
		card = scn_inspect_card.instantiate() as InspectCard
		card._node = node
		card.icon.set_icon(node)
		_inspect_cards[node] = card
	return card

static func show_card(node:Node):
	var ui = GameUI.get_ui()
	var card:InspectCard = InspectCard.get_existing(node)
	if not card.get_child_count():
		return l.warn('InspectCard has no properties added, node=%s', [node])
	ui.inspect_list.add_child(card)

static func hide_card(node:Node):
	var ui = GameUI.get_ui()
	var card:InspectCard = InspectCard.get_existing(node)
	card.get_parent().remove_child(card)

static func add_properties(node:Node, properties:Array[Dictionary], property_node:Node = node):
	var card:InspectCard = InspectCard.get_existing(node)
	for prop in properties:
		card._add_property(node, prop, property_node)
	
static func remove_properties(node:Node, properties:Array[Dictionary]):
	var card:InspectCard = InspectCard.get_existing(node)
	for prop in properties:
		card._remove_property(node, prop)
	

@export var icon:Icon
@export var attribute_list:BoxContainer

## The main node that this card focuses on
var _node:Node

func has_attribute(node:Node, attr:Dictionary):
	var type := attr.get('type') as InspectCard.INSPECT_TYPE
	var property := attr.get('property') as String
	var children = attribute_list.get_children()
	return attribute_list.get_children().any(func(c):
		return c is InspectAttribute and c.args.get('property') == property and c.args.get('type') == type
	)

func _add_property(node:Node, attr:Dictionary, property_node:Node = node):
	var type := attr.get('type') as InspectCard.INSPECT_TYPE
	
	if not scenes.has(type):
		return l.warn('Inspection type "%s" not found', [InspectCard.INSPECT_TYPE.find_key(type)])
	
	if has_attribute(node, attr):
		return # Attribute already added	
	# add to AttributeList
	var scene:PackedScene = scenes[type]
	var attribute_node:InspectAttribute = scene.instantiate() as InspectAttribute
	attribute_node.args = attr
	attribute_node.node = property_node
	attribute_list.add_child(attribute_node)

func _remove_property(node:Node, property:Variant):
	var children = attribute_list.get_children()\
		.filter(func(i:InspectAttribute):
			return i.node == node and \
				(property is String and i.args.get('property') == property) or\
				(property is Dictionary and i.args.get('property') == property.get('property')))
	for child in children:
		attribute_list.remove_child(child)
