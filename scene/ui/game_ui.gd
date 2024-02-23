class_name GameUI
extends Control

static var l = Log.new()
static var GROUP = 'game_ui'

static func get_ui() -> GameUI:
	return Global.get_tree().get_nodes_in_group(GROUP).front()

@onready var menu_buttons_container := $MarginContainer/VBoxContainer/MenuButtons
@onready var card_list := $MarginContainer/VBoxContainer/HBoxContainer/CardContainer/MarginContainer/CardList
@onready var inspect_list := $MarginContainer/VBoxContainer/HBoxContainer/InspectContainer/MarginContainer/InspectList

## Returns false if nothing was cleared
func clear_cards() -> bool:
	var nothing_cleared = !card_list.get_child_count()
	for child in card_list.get_children():
		card_list.remove_child(child)
	for map in TileMapHelper.get_all_instances():
		map.selection_enabled = false
	return !nothing_cleared

func _ready():	
	var menu_buttons = menu_buttons_container.get_children()
	for b in menu_buttons.size():
		var button = menu_buttons[b] as BaseButton
		# Setup neighbors
		if b > 0:
			button.focus_neighbor_left = (menu_buttons[b-1] as Control).get_path()
		if b+1 < menu_buttons.size():
			button.focus_neighbor_right = (menu_buttons[b+1] as Control).get_path()

func _gui_input(event):
	if event.is_action_pressed('cancel'):
		clear_cards()

