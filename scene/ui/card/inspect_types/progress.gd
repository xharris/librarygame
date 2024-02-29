class_name InspectProgress
extends InspectAttribute

static var l = Log.new()
static func build(property:String, label:String = property) -> Dictionary:
	return { 'type':InspectCard.INSPECT_TYPE.PROGRESS, 'property':property, 'label':label }

@export var label_node:Label
@export var progress_bar:ProgressBar
@export var fill_color:Color = Palette.Red500

var value:int = 100
var modulate_color:Color

func update_value(v):
	var label = args.get('label', _property) as String
	
	label_node.text = label
	if v > 0:
		modulate_color = Palette.Green500
		value = v as int
	else:
		modulate_color = Palette.Red500
		value = 100

func _process(delta):
	super(delta)
	progress_bar.value = lerpf(progress_bar.value, value, delta)
	progress_bar.modulate = progress_bar.modulate.lerp(modulate_color, delta)
