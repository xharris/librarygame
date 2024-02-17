class_name InspectText
extends InspectAttribute

static func build(property:String, format:String = '{0}') -> Dictionary:
	return { 'type':InspectCard.INSPECT_TYPE.TEXT, 'property':property, 'format':format }

var property:String
var label:String
var format:String = '{0}'

func update_value():
	var property = args.get('property') as String
	var format = args.get('format', format) as String
	
	var label_node := $MarginContainer/Label as Label
	var value = node[property]
	if not value is Array:
		value = [value]
	label_node.text = format.format(value)
