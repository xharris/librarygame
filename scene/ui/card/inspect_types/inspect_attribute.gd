class_name InspectAttribute
extends Control

var node:Node2D
var args:Dictionary = {}

func update_value():
	pass
	
func _on_update_value(node:Node, properties:Array[Dictionary]):
	for prop in properties:
		if node == node and prop.get('property', '') == args.get('property', ''):
			update_value()
		
func _ready():
	Events.inspect_card_update_value.connect(_on_update_value)
	update_value()
