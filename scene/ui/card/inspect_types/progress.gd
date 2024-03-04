class_name InspectProgress
extends InspectAttribute

static var l = Log.new()
static func build(property:String, label:String = property, red_green:bool = true, starting_value:int = 0) -> Dictionary:
	return { 'type':InspectCard.INSPECT_TYPE.PROGRESS, 'property':property, 'label':label, 'red_green':red_green, 'starting_value':starting_value }

@export var label_node:Label
@export var progress_bar:ProgressBar

var value:int = 0
var modulate_color:Color
var tween:Tween

func _update_color():
	var red_green := args.get('red_green', true) as bool
	if red_green:
		if value > 0:
			modulate_color = Palette.Green500
		else:
			modulate_color = Palette.Red500
	else:
		modulate_color = Palette.BlueGrey900

func update_value(v):
	var label := args.get('label', _property) as String
	var red_green := args.get('red_green', true) as bool
	value = v as int
	
	label_node.text = label
	if red_green and v == 0:
		value = 100
	_update_color()
	
func _ready():
	_update_color()
	value = args.get('starting_value', value) as int
	progress_bar.value = value

func _process(delta):
	super(delta)
	progress_bar.value = value
	progress_bar.modulate = progress_bar.modulate.lerp(modulate_color, delta)

func _on_update_timer_timeout():
	pass
	#if tween:
		#tween.kill()
	#tween = create_tween()
	#tween.tween_property(self, 'value', value, 0.5)
