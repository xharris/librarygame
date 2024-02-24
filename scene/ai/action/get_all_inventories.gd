extends ActionLeaf

enum SORT {DISTANCE,RANDOM}

@export var inventories_key:String
@export var sort:SORT
@export var avoid_actors = true
@export var avoid_map_tiles = true

func tick(actor, blackboard: Blackboard):
	var inventories:Array[Inventory] = []
	inventories.assign(Inventory.get_all())
	if avoid_actors:
		inventories = inventories.filter(func(i:Inventory):return not avoid_actors or not i.parent is Actor)
	if avoid_map_tiles:
		inventories = inventories.filter(func(i:Inventory):return not i.parent is MapTile)
	if actor is Node2D:
		match sort:
			SORT.DISTANCE:
				Global.sort_distance(actor, inventories)
			SORT.RANDOM:
				inventories.shuffle()
	blackboard.set_value(inventories_key, inventories)
	return SUCCESS

