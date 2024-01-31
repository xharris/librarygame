class_name Read
extends Task

@export var timer:Timer
var book_list:Array[int]

func _init():
	required_previous_state = ['Sit']

func is_task_needed() -> bool:
	return book_list.size() > 0
	
func enter(args:Dictionary):
	if not actor.inventory.has_item_type(Item.ITEM_TYPE.BOOK):
		# go get a book
		return fsm.set_state('GetItem', { item_filter=func(item:Item): return item.type == Item.ITEM_TYPE.BOOK })
	# stop and read for a while
	actor.stop_moving()
	if animation.current_animation != 'sit':
		animation.play('sit')
	timer.start(3)

func leave():
	animation.play('stand')

func _on_read_timer_timeout():
	# TODO change to StoreItem
	# TODO if patron has a library card, chance of StoreItem/leaving with item
	StationHelper.free_all_stations_by_type(fsm.actor, StationHelper.STATION_TYPE.SEAT)
	var item:Item = fsm.inventory.get_all_items().pick_random()
	if item:
		fsm.set_state('StoreItem', { item_id=item.id })
	else:
		fsm.set_state('Walk')
