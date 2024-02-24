class_name GameUI
extends Control

static var l = Log.new()
static var GROUP = 'game_ui'

static func get_ui() -> GameUI:
	return Global.get_tree().get_nodes_in_group(GROUP).front()

@export var inspect_list:BoxContainer# := $MarginContainer/VBoxContainer/HBoxContainer/InspectContainer/MarginContainer/InspectList

func _ready():
	pass
	#var menu_buttons = menu_buttons_container.get_children()
	#for b in menu_buttons.size():
		#var button = menu_buttons[b] as BaseButton
		## Setup neighbors
		#if b > 0:
			#button.focus_neighbor_left = (menu_buttons[b-1] as Control).get_path()
		#if b+1 < menu_buttons.size():
			#button.focus_neighbor_right = (menu_buttons[b+1] as Control).get_path()

func _gui_input(event):
	var map := TileMapHelper.get_current_map() as Map
	if event.is_action_pressed('cancel') and map:
		map.selection_enabled = false
	#if event.is_action_pressed('cancel'):
		#clear_cards()

