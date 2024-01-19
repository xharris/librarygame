extends Node

var fsm: ActorStateMachine
@export var nav_agent: NavigationAgent2D
@export var body: Actor
@onready var timer = $ReadTimer

func enter(args:Dictionary):
	nav_agent.target_position = body.global_position
	body.velocity = Vector2.ZERO
	var has_book = body.inventory.has_item_type(InventoryHelper.ITEM_TYPE.BOOK)
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
