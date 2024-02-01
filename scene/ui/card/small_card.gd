class_name SmallCard
extends PanelContainer

var l = Log.new(Log.LEVEL.DEBUG)

@export var title_label:RichTextLabel
@export var description_label:RichTextLabel
@export var flavor_text_label:RichTextLabel
@export var label_container:Container
@export var label_super_container:Container
@export var title_description_separator:Control
@export var icon:SubViewport

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
		if 'center' in node and node.center is Marker2D:
			var camera = $HBoxContainer/AspectRatioContainer/Icon/SubViewport/Camera2D
			camera.global_position = node.center.global_position
		#icon.get_camera_2d().global_position = node.global_position
		#await RenderingServer.frame_post_draw
		#(icon as SubViewport).get_texture()
	else:
		for child in icon.get_children():
			icon.remove_child(child)

func config(object:Node2D):
	var child = object.find_child('Station') 
	if not child:
		child = object.find_child('Actor')
	if child:
		if 'title' in child:
			set_title(child.title)
		if 'description' in child:
			set_description(child.description)
		if 'flavor_text' in child:
			set_flavor_text(child.flavor_text)
		var icon = child.duplicate()
		if icon is Station:
			icon.enabled = false
		if icon is Actor:
			icon.process_mode = Node.PROCESS_MODE_DISABLED
		set_icon(icon)
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
