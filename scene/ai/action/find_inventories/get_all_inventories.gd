extends ActionLeaf

enum SORT {NONE,DISTANCE}

@export var inventories_key:String = 'inventories'
@export var sort:SORT = SORT.DISTANCE

func tick(actor, blackboard: Blackboard):
	var inventories = Inventory.get_all()
	if sort == SORT.DISTANCE:
		Global.sort_distance(actor, inventories)
	blackboard.set_value(inventories_key, inventories)
	return SUCCESS

