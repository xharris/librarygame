class_name InspectCard
extends PanelContainer

static var l = Log.new()
static var GROUP = 'inspect_card'
enum INSPECT_TYPE {TEXT, PROGRESS}
static var scenes = {
	INSPECT_TYPE.TEXT: preload('res://scene/ui/card/inspect_types/text.tscn'),
	INSPECT_TYPE.PROGRESS: preload('res://scene/ui/card/inspect_types/progress.tscn')
}
static var scn_inspect_section = preload('res://scene/ui/card/inspect_section.tscn')
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

static func add_properties(node:Node, properties:Array[Dictionary], property_node:Node = node, section:String = ''):
	var card:InspectCard = InspectCard.get_existing(node)
	for prop in properties:
		card._add_property(node, prop, property_node, section)
	
static func remove_properties(node:Node, properties:Array[Dictionary]):
	var card:InspectCard = InspectCard.get_existing(node)
	for prop in properties:
		card._remove_property(node, prop)

@export var icon:Icon
@export var section_list:BoxContainer

## The main node that this card focuses on
var _node:Node

func _get_section(section_name:String) -> InspectSection:
	var children = section_list.get_children()
	var sections = children.filter(func(c):
		return c is InspectSection and c.section_name == section_name)
	var section:InspectSection
	if sections.size():
		section = sections.front()
	if not section:
		# Add new section
		section = scn_inspect_section.instantiate()
		section.section_name = section_name
		section_list.add_child(section)
	return section

func has_property(node:Node, attr:Dictionary):
	var type := attr.get('type') as InspectCard.INSPECT_TYPE
	var property := attr.get('property') as String
	for section in section_list.get_children():
		if section_list.get_children().any(func(c):
			return c is InspectAttribute and c.args.get('property') == property and c.args.get('type') == type
		):
			return true
	return false

func _add_property(node:Node, attr:Dictionary, property_node:Node = node, section_name:String = ''):
	var type := attr.get('type') as InspectCard.INSPECT_TYPE
	if not scenes.has(type):
		return l.warn('Inspection type "%s" not found', [InspectCard.INSPECT_TYPE.find_key(type)])
	if has_property(node, attr):
		return # Attribute already added
	var section = _get_section(section_name)
	# add to AttributeList
	var scene:PackedScene = scenes[type]
	var attribute_node:InspectAttribute = scene.instantiate() as InspectAttribute
	attribute_node.args = attr
	attribute_node.node = property_node
	section.add_child(attribute_node)

func _remove_property(node:Node, property:Variant):
	for section in section_list.get_children():
		var children = section.get_children()\
			.filter(func(i:InspectAttribute):
				return i.node == node and \
					(property is String and i.args.get('property') == property) or\
					(property is Dictionary and i.args.get('property') == property.get('property')))
		for child in children:
			section.remove_child(child)

func _on_close_button_pressed():
	get_parent().remove_child(self)
