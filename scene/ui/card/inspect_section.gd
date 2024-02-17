class_name InspectSection
extends Control

@export var label:Label

var section_name:String:
	set(value):
		label.text = value
	get:
		return label.text
