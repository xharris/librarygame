class_name Item
extends Node2D

enum ITEM_TYPE {BOOK,FOOD,DRINK}
static var next_id = 1
static var _templates:Dictionary = {}

class ItemTemplate:
	var id:int
	var item_name:String
	var type:ITEM_TYPE

static func register_item(item_name:String, type:ITEM_TYPE, args:Dictionary = {}) -> int:
	var templates = get_all()
	if templates.filter(func(item):item.item_name == item_name).size() > 0:
		push_warning('Duplicate item name: ',item_name)
	var template = ItemTemplate.new()
	template.id = next_id
	template.item_name = item_name
	template.type = type
	_templates[template.id] = template
	next_id += 1
	return template.id

static func find_item(filter:Callable) -> ItemTemplate:
	var templates = get_all()
	if filter.is_null():
		templates = templates.filter(filter)
	if templates.size():
		return templates.front()
	return

static func create_from_id(id:int) -> Item:
	if not _templates.has(id):
		push_error('Item not found. id=',id)
		return
	var template := _templates.get(id) as ItemTemplate
	var item = Item.new()
	item.id = template.id
	item.item_name = template.item_name
	return item

static func get_all() -> Array[ItemTemplate]:
	var templates:Array[ItemTemplate]
	templates.assign(_templates.values())
	return templates

@export var type:ITEM_TYPE
var id:int
var item_name:String
var args:Dictionary

func clone() -> Item:
	var new_item = new()
	new_item.id = id
	new_item.item_name = item_name
	new_item.type = type
	return new_item

func _ready():
	var parent = get_parent()
	if parent and 'config' in parent:
		parent.config(args)
