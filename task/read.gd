class_name Read
extends Task

@onready var timer:Timer = $ReadTimer
var current_book:int = -1
var book_list:Array[int]

func is_task_needed(actor:Actor) -> bool:
	return book_list.size() > 0

func get_prep_steps(actor:Actor):
	if not actor.inventory.has_item_type(Item.ITEM_TYPE.BOOK):
		# go get a book
		add_prep_state('GetItem', { item_filter=func(item:Item): return item.type == Item.ITEM_TYPE.BOOK })
	if not StationHelper.get_using(actor).any(func(s:Station):return s.type == Station.STATION_TYPE.SEAT):
		add_prep_state('Sit')

func enter(args:Dictionary):
	current_book = book_list.pick_random()
	timer.start(3)

func leave():
	book_list = book_list.filter(func(b):return b != current_book)
	current_book = -1

func _on_read_timer_timeout():
	fsm.set_state('Idle')
