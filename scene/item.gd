class_name Item
extends Node2D

static var l = Log.new()

static var ITEM_PATH = 'res://scene/item'

enum ITEM_TYPE {BOOK,FOOD,DRINK}
static var next_id = 1
static var _templates:Dictionary = {}

var scn_item := preload('res://scene/item.tscn')

class ItemTemplate:
	var id:int
	var item_name:String
	var type:ITEM_TYPE
	var scene:PackedScene

static func register_item(item_name:String, type:ITEM_TYPE, args:Dictionary = {}) -> int:
	var templates = get_all()
	if templates.filter(func(item):item.item_name == item_name).size() > 0:
		push_warning('Duplicate item name: ',item_name)
	var template = ItemTemplate.new()
	template.id = next_id
	template.item_name = item_name
	template.type = type
	# get packed scene
	var item_scene:Node2D
	var scene_path = ITEM_PATH+'/'+(ITEM_TYPE.find_key(template.type) as String).to_lower()+'.tscn'
	if FileAccess.file_exists(scene_path):
		template.scene = load(scene_path)
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

static func create_from_id(id:int) -> Node2D:
	if not _templates.has(id):
		push_error('Item not found. id=',id)
		return
	var template := _templates.get(id) as ItemTemplate
	if template.scene:
		var node = template.scene.instantiate()
		var item = Item.get_item_node(node)
		if not item:
			l.warn('Item template does not have Item node: %s', [template])
			return
		item.id = template.id
		item.item_name = template.item_name
		return node
	return

static func get_all() -> Array[ItemTemplate]:
	var templates:Array[ItemTemplate]
	templates.assign(_templates.values())
	return templates

static func get_item_node(node:Node2D) -> Item:
	return node.find_child('Item') as Item
	
@export var type:ITEM_TYPE
var id:int
var item_name:String
var args:Dictionary

func _ready():
	var parent = get_parent()
	if parent and 'config' in parent:
		parent.config(args)
