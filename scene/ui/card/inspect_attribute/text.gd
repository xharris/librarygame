class_name InspectText
extends InspectAttribute

static func build(property:String, label:String = property, format:String = '{0}') -> Dictionary:
	return { 'type':InspectCard.INSPECT_TYPE.TEXT, 'property':property, 'label':label, 'format':format }

var property:String
var label:String
var format:String = '{0}'

func update_value():
	var label := $MarginContainer/Label as Label
	label.text = format.format([node[property]])

func _ready():
	property = args.get('property') as String
	label = args.get('label', property) as String
	format = args.get('format', format) as String
	# text value
	update_value()
	node.property_list_changed.connect(func(): update_value())
