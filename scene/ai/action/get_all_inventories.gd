extends ActionLeaf

enum SORT {DISTANCE,RANDOM}

@export var inventories_key:String
@export var sort:SORT

func tick(actor, blackboard: Blackboard):
	var inventories:Array[Inventory] = []
	inventories.assign(Inventory.get_all())
	if actor is Node2D:
		match sort:
			SORT.DISTANCE:
				Global.sort_distance(actor, inventories)
			SORT.RANDOM:
				inventories.shuffle()
	blackboard.set_value(inventories_key, inventories)
	return SUCCESS

