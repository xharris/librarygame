class_name Item
extends Node2D

enum TYPE {BOOK,FOOD,KEY}
static var scene = preload('res://scene/item.tscn')
static var GROUP = 'item'

static func get_all() -> Array[Item]:
	var items:Array[Item] = []
	items.assign(Global.get_tree().get_nodes_in_group(GROUP))
	return items

var type:TYPE
var item_name:String
var args:Dictionary

func add_texture(path:String, color:Color = Color.WHITE) -> Sprite2D:
	var texture = load(path) as Texture2D
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.modulate = color
	sprite.centered = true
	var size = texture.get_size()
	var shape:CollisionShape2D = %InputShape
	var actual_shape = shape.shape as RectangleShape2D
	actual_shape.size.x = max(actual_shape.size.x, size.x)
	actual_shape.size.y = max(actual_shape.size.y, size.y)
	add_child(sprite)
	return sprite

func _ready():
	var name_property := %Name as InspectPropertyHelper
	if type == TYPE.BOOK:
		name_property.label = '"{0}"'
	else:
		name_property.label = '{0}'

