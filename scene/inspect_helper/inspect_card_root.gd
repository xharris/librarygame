class_name InspectCardRoot
extends Node2D

static var GROUP = 'inspect_card_root'

@export var node:Node2D

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('select'):
		InspectCard.show_card(node)
