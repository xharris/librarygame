extends Task

@onready var timer = $ReadTimer

func _init():
	required_previous_state = ['Sit']

func is_task_needed() -> bool:
	return actor.inventory.has_item_type(InventoryHelper.ITEM_TYPE.BOOK)
	
func enter(args:Dictionary):
	var has_book = actor.inventory.has_item_type(InventoryHelper.ITEM_TYPE.BOOK)
	if has_book:
		# stop and read for a while
		timer.start(3)
	else:
		# go get a book
		return fsm.set_state('GetItem', { 
			item_filter=func(item:InventoryHelper.Item): return item.type == InventoryHelper.ITEM_TYPE.BOOK 
		})

func _on_read_timer_timeout():
	fsm.set_state('Idle')
