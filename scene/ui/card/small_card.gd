class_name SmallCard
extends PanelContainer

enum SCENE_TYPE {STATION,ACTOR}

var l = Log.new(Log.LEVEL.DEBUG)

@export var title_label:RichTextLabel
@export var description_label:RichTextLabel
@export var flavor_text_label:RichTextLabel
@export var label_container:Container
@export var label_super_container:Container
@export var title_description_separator:Control
@export var icon:SubViewport
var scene:PackedScene
var scene_type:SCENE_TYPE

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

func set_icon(node:Node2D = null):
	icon.get_parent().visible = node != null
	if node:
		icon.add_child(node)
		var marker = Global.iterate_children_until(node, func(c):return c is Marker2D) as Marker2D
		if marker:
			var camera = $HBoxContainer/AspectRatioContainer/Icon/SubViewport/Camera2D
			camera.global_position = marker.global_position
		#icon.get_camera_2d().global_position = node.global_position
		#await RenderingServer.frame_post_draw
		#(icon as SubViewport).get_texture()
	else:
		for child in icon.get_children():
			icon.remove_child(child)

func config():
	if not scene:
		l.warn('`scene` not set')
		return
	var object = scene.instantiate()
	object.process_mode = Node.PROCESS_MODE_DISABLED
	var child = object.find_child('Station')
	if child:
		scene_type = SCENE_TYPE.STATION
	if not child:
		child = object.find_child('Actor') as Actor
		if child:
			scene_type = SCENE_TYPE.ACTOR
			## TODO disable the actor somehow
	if child:
		if 'title' in child:
			set_title(child.title)
		else:
			set_title('')
		if 'description' in child:
			set_description(child.description)
		else:
			set_description('')
		if 'flavor_text' in child:
			set_flavor_text(child.flavor_text)
		else:
			set_flavor_text('')
		if object is Station:
			icon.enabled = false
		if object is Actor:
			pass
		set_icon(object)
	mouse_filter = Control.MOUSE_FILTER_STOP

func _ready():
	config()

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
