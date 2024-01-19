extends Node

enum ITEM_TYPE {BOOK,FOOD,DRINK}

func find_item(filter:Callable) -> Item:
	var items:Array[Item]
	items.assign(Item.get_all().filter(filter))
	return items.front()

## Search all inventories for an item
func find_inventory_with_item(item_id:int) -> Array[Inventory]:
	return Inventory.instances.filter(func(i:Inventory): return i.has_item(item_id))

class Inventory extends Node:
	static var instances: Array[Inventory]
	
	var node:Node2D
	var items:Array[Item]

	func _init(parent:Node):
		node = parent
		instances.append(self)

	func has_item(id:int) -> bool:
		return items.filter(func(i:Item): return i.id == id).size() > 0
		
	func add_item(item:Item):
		items.append(item)

	## Move an item from one inventory to another
	## TODO show item bouncing from this inventory to other one
	func transfer_item(item_id:int, other:Inventory):
		# find item
		var found_item:Item
		for item in items:
			if item.id == item_id:
				found_item = item
		if not found_item:
			print('Item ',item_id,' not found in ',self)
			return
		# move to other inventory
		other.items.append(found_item)

class Item extends Node:
	static var next_id = 1
	static var templates = {}

	static func register_item(item_name:String, type:ITEM_TYPE) -> int:
		if templates.values().filter(func(item):item.item_name == item_name).size() > 0:
			push_warning('Duplicate item name: ',item_name)
		var item = new()
		item.id = next_id
		item.item_name = item_name
		item.type = type
		templates[item.id] = item
		next_id += 1
		return item.id

	static func create_from_id(id:int) -> Item:
		if not templates.has(id):
			push_error('Item not found. id=',id)
			return
		var item := templates.get(id) as Item
		return item.clone()

	static func get_all() -> Array[Item]:
		var items:Array[Item]
		items.assign(templates.values())
		return items

	var type:ITEM_TYPE
	var id:int
	var item_name:String

	func clone() -> Item:
		var new_item = new()
		new_item.id = id
		new_item.item_name = item_name
		new_item.type = type
		return new_item

func _ready():
	Item.register_item('rich dad poor dad', ITEM_TYPE.BOOK)
