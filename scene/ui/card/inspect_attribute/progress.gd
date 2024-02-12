class_name InspectProgress
extends InspectAttribute

static var l = Log.new()
static func build(property:String, label:String = property, min:int = 0, max:int = 100) -> Dictionary:
	return { 'type':InspectCard.INSPECT_TYPE.PROGRESS, 'property':property, 'label':label, 'min':min, 'max':max }

var property:String
var label:String
var min:int = 0
var max:int = 100

func update_value():
	var label_node := $MarginContainer/HBoxContainer/Label as Label
	var progress_bar := $MarginContainer/HBoxContainer/ProgressBar as ProgressBar
	
	label_node.text = property
	progress_bar.value = (node[property]-min) / (max-min) * 100

# Called when the node enters the scene tree for the first time.
func _ready():
	property = args.get('property') as String
	label = args.get('label', property) as String
	min = args.get('min', min) as int
	max = args.get('max', max) as int
	# progress value
	update_value()
	node.property_list_changed.connect(func(): update_value())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
