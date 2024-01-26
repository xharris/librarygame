class_name Inventory
extends Node2D

static var instances: Array[Inventory]

static func find_closest(to:Node2D) -> Inventory:
	instances.sort_custom(func(a:Inventory,b:Inventory): 
		return a.node.global_position.distance_to(to.global_position) <  b.node.global_position.distance_to(to.global_position)
	)
	return instances.front()

## Search all inventories for an item
static func find_inventory_with_item(item_id:int) -> Array[Inventory]:
	return Inventory.instances.filter(func(i:Inventory): return i.has_item(item_id))

var node:Node2D
var items:Array[Item]
var disabled = false

func _ready():
	node = get_parent()
	instances.append(self)

func has_item(id:int) -> bool:
	return items.any(func(i:Item): return i.id == id)
	
func has_item_type(type:Item.ITEM_TYPE) -> bool:
	return items.any(func(i:Item): return i.type == type)
	
func add_item(item:Item) -> Inventory:
	if not disabled:
		items.append(item)
	return self

func get_items(id:int) -> Array[Item]:
	return items.filter(func(i:Item): return i.id == id)

## Move an item from one inventory to another
## Returns true on success
## TODO show item bouncing from this inventory to other one
func transfer_item(item_id:int, to:Inventory) -> bool:
	if to.disabled:
		return false
	# find item
	var found_item:Item
	for item in items:
		if item.id == item_id:
			found_item = item
	if not found_item:
		return false
	# move to other inventory
	to.items.append(found_item)
	return true
	
## TODO add inventory for nearest tile on current map, move item to tile's inventory
## TODO visually place item on the tile
func drop_item(item:Item):
	var drop_position = node.global_position
