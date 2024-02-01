class_name Station
extends Node2D

var l = Log.new()
static var GROUP = 'station'

@onready var animation:AnimationPlayer = $AnimationPlayer
@onready var inventory:Inventory = $Inventory
@export var title:String = 'Station'
@export var description:String = ''
@export var flavor_text:String = ''
@export var sprite:Node2D
@export var max_occupancy = 1
@export var type:StationHelper.STATION_TYPE
@export var center:Node2D
var enabled = true
@export var has_inventory:bool = false

var users:Array[Node2D] = []

func can_use():
	return users.size() < max_occupancy and enabled and is_visible_in_tree()

func use(node:Node2D):
	if type == StationHelper.STATION_TYPE.SEAT:
		# NOTE Vector2(0,1) makes node appear above station when Y sort is enabled
		node.global_position = global_position + Vector2(0,1)
		if node is Actor:
			if center:
				node.sprite_transform.position += center.position
			node.stop_moving()
			# TODO face same direction as station?
	users.append(node)

func done_using(node:Node2D):
	if node is Actor:
		if center:
			node.sprite_transform.position -= center.position
	users = users.filter(func(u:Node): return u != node)
	
## Remove from map
func remove():
	# make users walk away
	for user in users:
		done_using(user)
		if user is Actor:
			user.fsm.set_state('Walk')
	get_parent().remove_child(self)
	
func _ready():
	add_to_group(GROUP)

func _process(delta):
	if center:
		inventory.position = center.position

func _on_inventory_item_stored(item:Item):
	animation.play('store_item')

func _on_inventory_item_removed(item:Item):
	animation.play('get_item')
