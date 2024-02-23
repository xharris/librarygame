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
	add_child(sprite)
	return sprite
