class_name InspectCard
extends PanelContainer

static var l = Log.new()
static var GROUP = 'inspect_card'
enum INSPECT_TYPE {TEXT, PROGRESS}
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

func _get_section(section_name:String = 'info') -> InspectSection:
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

func _get_all_sections() -> Array[InspectSection]:
	var sections:Array[InspectSection] = []
	sections.assign(section_list.get_children())
	return sections

func _get_property_key(node:Node, attr:Dictionary, section_name:String = ''):
	return '-'.join([str(node), str(attr), section_name])

func has_property(node:Node, attr:Dictionary) -> bool:
	return _get_all_sections().any(func(s:InspectSection):return s.has_attribute(node, attr))

func _add_property(node:Node, attr:Dictionary, property_node:Node = node, section_name:String = ''):
	var section = _get_section(section_name)
	section.add_attribute(node, attr, property_node)

func _remove_property(node:Node, attr:Variant):
	for section in _get_all_sections():
		# remove from section
		if section.has_attribute(node, attr):
			section.remove_attribute(node, attr)
		# remove empty section?
		if not section.get_all_attributes().size():
			section_list.remove_child(section)

func _on_close_button_pressed():
	get_parent().remove_child(self)
