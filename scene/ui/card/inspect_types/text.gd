class_name InspectText
extends InspectAttribute

static func build(property:String, format:String = '{0}') -> Dictionary:
	return { 'type':InspectCard.INSPECT_TYPE.TEXT, 'property':property, 'format':format }

var label:String
var format:String = '{0}'

func update_value(value:Variant):
	var format = args.get('format', format) as String
	
	var label_node := $MarginContainer/Label as Label
	if not value is Array:
		value = [value]
	label_node.text = format.format(value)
