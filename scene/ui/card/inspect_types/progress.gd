class_name InspectProgress
extends InspectAttribute

static var l = Log.new()
static func build(property:String, label:String = property) -> Dictionary:
	return { 'type':InspectCard.INSPECT_TYPE.PROGRESS, 'property':property, 'label':label }

@export var label_node:Label
@export var progress_bar:ProgressBar

func update_value():
	var property = args.get('property') as String
	var label = args.get('label', property) as String
	
	label_node.text = label
	progress_bar.value = node[property] as int
