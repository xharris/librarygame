class_name Item
extends Node2D

enum ITEM_TYPE {BOOK,FOOD,DRINK}
static var next_id = 1
static var templates = {}

static func _static_init():
	register_item('rich dad poor dad', ITEM_TYPE.BOOK)

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

static func find_item(filter:Callable) -> Item:
	var items:Array[Item]
	items.assign(Item.get_all().filter(filter))
	return items.front()

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
