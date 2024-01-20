extends Task

@onready var timer = $ReadTimer

func _init():
	required_previous_state = ['Sit']

func is_task_needed() -> bool:
	return actor.inventory.has_item_type(InventoryHelper.ITEM_TYPE.BOOK)
	
func enter(args:Dictionary):
	if not actor.inventory.has_item_type(InventoryHelper.ITEM_TYPE.BOOK):
		# go get a book
		return fsm.set_state('GetItem', { 
			item_filter=func(item:InventoryHelper.Item): return item.type == InventoryHelper.ITEM_TYPE.BOOK 
		})
	# stop and read for a while
	timer.start(3)

func _on_read_timer_timeout():
	# TODO change to StoreItem
	# TODO if patron has a library card, chance of StoreItem/leaving with item
	fsm.set_state('Walk')
