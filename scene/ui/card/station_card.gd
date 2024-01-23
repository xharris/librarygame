class_name StationCard
extends Control

var log = Log.new(Log.LEVEL.DEBUG)

@export var title_label:RichTextLabel
@export var description_label:RichTextLabel
@export var flavor_text_label:RichTextLabel
@export var label_container:Container
@export var label_super_container:Container
@export var icon:SubViewport

signal pressed

func _update_label_visibility(text:String, label:Control):
	label.visible = text.length() > 0

func set_title(title:String = ''):
	title_label.text = title
	_update_label_visibility(title, title_label)

func set_description(description:String = ''):
	description_label.text = description
	_update_label_visibility(description, description_label)

func set_flavor_text(flavor_text:String = ''):
	flavor_text_label.text = flavor_text
	_update_label_visibility(flavor_text, flavor_text_label)

func set_icon(node:Node2D = null):
	icon.get_parent().visible = node != null
	if node:
		icon.add_child(node)
		#icon.get_camera_2d().global_position = node.global_position
		#await RenderingServer.frame_post_draw
		#(icon as SubViewport).get_texture()
	else:
		for child in icon.get_children():
			icon.remove_child(child)

func _on_pressed():
	pressed.emit()

func _on_mouse_entered():
	label_super_container.visible = true

func _on_mouse_exited():
	label_super_container.visible = false
	
func _on_focus_entered():
	label_super_container.visible = true

func _on_focus_exited():
	label_super_container.visible = false
