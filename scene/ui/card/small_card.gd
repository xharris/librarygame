class_name SmallCard
extends PanelContainer

enum SCENE_TYPE {STATION,ACTOR}

var l = Log.new()

@export var title_label:RichTextLabel
@export var description_label:RichTextLabel
@export var flavor_text_label:RichTextLabel
@export var label_container:Container
@export var label_super_container:Container
@export var title_description_separator:Control
@export var icon:Icon
var node:Node
var scene:PackedScene
var scene_type:SCENE_TYPE ## TODO is this needed? remove?

signal pressed(event:InputEvent)

func _update_label_visibility(text:String, label:Control):
	label.visible = text.length() > 0

func set_title(title:String = ''):
	title_label.text = title
	_update_label_visibility(title, title_label)
	title_description_separator.visible = title_label.visible and description_label.visible

func set_description(description:String = ''):
	description_label.text = description
	_update_label_visibility(description,description_label)
	title_description_separator.visible = title_label.visible and description_label.visible

func set_flavor_text(flavor_text:String = ''):
	flavor_text_label.text = flavor_text
	_update_label_visibility(flavor_text, flavor_text_label)

func _ready():
	if not scene:
		l.warn('`scene` not set')
		return
	# instantiate from scene?
	if scene and not node:
		node = scene.instantiate()
		node.process_mode = Node.PROCESS_MODE_DISABLED
		if node.find_child('Station') as Station:
			scene_type = SCENE_TYPE.STATION
		if node.find_child('Actor') as Actor:
			scene_type = SCENE_TYPE.ACTOR
	# configure text/icon
	set_title(tr("%s_TITLE" % node.name.to_upper()).strip_edges())
	set_description(tr("%s_DESCRIPTION" % node.name.to_upper()).strip_edges())
	set_flavor_text(tr("%s_FLAVOR_TEXT" % node.name.to_upper()).strip_edges())
	if node is Station:
		icon.enabled = false
	if node is Actor:
		pass
	icon.set_icon(node)
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_mouse_entered():
	label_super_container.visible = true

func _on_mouse_exited():
	label_super_container.visible = false
	
func _on_focus_entered():
	label_super_container.visible = true

func _on_focus_exited():
	label_super_container.visible = false

func _on_gui_input(event:InputEvent):
	if event.is_action_pressed('select'):
		pressed.emit(event)
