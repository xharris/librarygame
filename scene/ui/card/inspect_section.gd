class_name InspectSection
extends Control

static var l = Log.new()
static var scenes = {
	InspectCard.INSPECT_TYPE.TEXT: preload('res://scene/ui/card/inspect_types/text.tscn'),
	InspectCard.INSPECT_TYPE.PROGRESS: preload('res://scene/ui/card/inspect_types/progress.tscn')
}

var section_name:String:
	set(value):
		var label := %Label as Label
		label.text = value
		# show/hide label
		label.visible = value.length() > 0
	get:
		var label := %Label as Label
		return label.text

func get_all_attributes() -> Array[InspectAttribute]:
	var attributes:Array[InspectAttribute] = []
	attributes.assign(get_children().filter(func(c):return c is InspectAttribute))
	return attributes

func has_attribute(node:Node, attribute:Variant) -> bool:
	return get_all_attributes().any(func(i:InspectAttribute):return i.is_attribute(node, attribute))

func add_attribute(node:Node, attr:Variant, property_node:Node = node):
	# get scene
	var type := attr.get('type') as InspectCard.INSPECT_TYPE
	if not scenes.has(type):
		return l.warn('Inspection type "%s" not found', [InspectCard.INSPECT_TYPE.find_key(type)])
	if has_attribute(node, attr):
		return # Attribute already added
	# add to AttributeList
	var scene:PackedScene = scenes[type]
	var attribute_node:InspectAttribute = scene.instantiate() as InspectAttribute
	attribute_node.args = attr
	attribute_node.node = node
	attribute_node.property_node = property_node
	attribute_node._property = attr.get('property')
	add_child(attribute_node)
	
func remove_attribute(node:Node, attr:Variant):
	for attribute in get_all_attributes():
		if attribute.is_attribute(node, attr):
			remove_child(attribute)
