class_name NotificationCard
extends PanelContainer

static var scn_notification_card = preload('res://scene/ui/card/notification_card.tscn')

static func show_notification(text:String, close_after:float = 3):
	var game_ui = GameUI.get_ui()
	if not game_ui:
		return
	var card := scn_notification_card.instantiate() as NotificationCard
	card.text = text
	card.close_after = close_after
	game_ui.inspect_list.add_child(card)

@onready var close_button:Button = %Close
@onready var label:Label = %Label
@onready var close_timer:Timer = $CloseTimer
@onready var progress_bar:ProgressBar = %ProgressBar
var text:String
var close_after:float = -1
var _mouse_hovering:bool = false

func _hide():
	get_parent().remove_child(self)

func _process(delta):
	label.text = text
	if not _mouse_hovering and close_after > -1 and close_timer.is_stopped():
		close_timer.wait_time = close_after
		close_timer.start()
	if close_after > -1:
		progress_bar.visible = true
		progress_bar.value = (close_timer.wait_time - close_timer.time_left) / close_timer.wait_time * 100
	else:
		progress_bar.visible = false

func _on_close_pressed():
	_hide()

func _on_close_timer_timeout():
	_hide()

func _on_mouse_entered():
	_mouse_hovering = true
	close_timer.paused = true

func _on_mouse_exited():
	_mouse_hovering = false
	if close_after > -1:
		close_timer.paused = false
		close_timer.start()
