class_name Station
extends Node2D

@export var title:String = 'Station'
@export var description:String = ''
@export var flavor_text:String = ''
@export var sprite:Node2D
@export var max_occupancy = 1
@export var type:StationHelper.STATION_TYPE
@export var sit_offset = Vector2(0,1)
var enabled = true

var users:Array[Node2D] = []
var inventory = InventoryHelper.Inventory.new(self)

func can_use():
	return users.size() < max_occupancy and enabled

func use(node:Node2D):
	if type == StationHelper.STATION_TYPE.SEAT:
		node.global_position = global_position
		if node is Actor:
			node.sprite_transform.position += sit_offset
			node.stop_moving()
			# TODO face same direction as station
	users.append(node)

func done_using(node:Node2D):
	if node is Actor:
		node.sprite_transform.position -= sit_offset
	users = users.filter(func(u:Node): return u != node)
	
## Remove from map
func remove():
	# make users walk away
	for user in users:
		if user is Actor:
			user.fsm.set_state('Walk')
	# drop items on ground
	for item in inventory.items:
		inventory.drop_item(item)
	get_parent().remove_child(self)
	
func _ready():
	add_to_group('station')
