class_name GameUI
extends Control

static var l = Log.new()
static var GROUP = 'game_ui'

static func get_ui() -> GameUI:
	return Global.get_tree().get_nodes_in_group(GROUP).front()

@export var inspect_list:BoxContainer# := $MarginContainer/VBoxContainer/HBoxContainer/InspectContainer/MarginContainer/InspectList
@export var game_day_label:Label
@export var game_time_label:Label
@export var money_label:Label

func _gui_input(event):
	var map := TileMapHelper.get_current_map() as Map
	if event.is_action_pressed('cancel') and map:
		map.selection_enabled = false

func _process(delta):
	var manager = GameManager.get_current()
	#game_time_label.text = 'Day %d (%d:%s)'%[manager.cycle, game_hours, game_minutes if game_minutes > 10 else '0'+str(game_minutes)]
	var dt = manager.dt
	game_day_label.text = str(dt.days)
	game_time_label.text = '%d %s\n%s'%[dt.hours12, dt.meridiem, 
		tr(DayNight.PART.find_key(DayNight.get_cycle(manager.cycle_progress)))]
	money_label.text = '$%d'%[manager.money]
