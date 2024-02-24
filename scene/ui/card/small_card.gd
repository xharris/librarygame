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
var object:Variant
var text_key:String

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
	# get text key
	var node:Node
	if object is PackedScene:
		node = object.instantiate()
		node.process_mode = Node.PROCESS_MODE_DISABLED
	if object is Node:
		node = node
	if object is String:
		text_key = object.to_upper()
	if node:
		text_key = node.name.to_upper()
	if not text_key:
		return l.error("Couldn't extract text_key from %s",[object])
	# configure text/icon
	set_title(tr("%s_TITLE" % text_key).strip_edges())
	set_description(tr("%s_DESCRIPTION" % text_key).strip_edges())
	set_flavor_text(tr("%s_FLAVOR_TEXT" % text_key).strip_edges())
	if node is Node:
		icon.set_icon(node)
	mouse_filter = Control.MOUSE_FILTER_STOP

#func _on_mouse_entered():
	#label_super_container.visible = true
#
#func _on_mouse_exited():
	#label_super_container.visible = false
	#
#func _on_focus_entered():
	#label_super_container.visible = true
#
#func _on_focus_exited():
	#label_super_container.visible = false

func _on_gui_input(event:InputEvent):
	if event.is_action_pressed('select'):
		pressed.emit(event)
