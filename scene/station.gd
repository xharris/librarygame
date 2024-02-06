class_name Station
extends Node2D

var l = Log.new(Log.LEVEL.DEBUG)
static var GROUP = 'station'
enum STATION_TYPE {SEAT,STORAGE,DOOR}

@onready var animation:AnimationPlayer = $AnimationPlayer
@onready var inventory:Inventory = $Inventory
@export var title:String = 'Station'
@export var description:String = ''
@export var flavor_text:String = ''
@export var max_occupancy = 1
@export var type:Station.STATION_TYPE
@export var center:Node2D
var enabled = true
var _previous_parent:Dictionary = {}

func is_solid() -> bool:
	return type != STATION_TYPE.DOOR

func is_active() -> bool:
	return find_parent('Map') != null

func get_users() -> Array[Actor]:
	var actors:Array[Actor]
	actors.assign(get_children().filter(func(a:Node):return a is Actor))
	return actors

func get_user_count() -> int:
	return get_users().size()

func can_use(node:Actor):
	return (get_user_count() < max_occupancy or has_user(node)) and enabled and is_active()

func get_center() -> Node2D:
	if not center:
		return self
	return center

var real_global_position:Vector2:
	get:
		return get_parent().global_position

func has_user(node:Actor) -> bool:
	return get_users().has(node)

func use(node:Actor):
	l.debug('%s use %s (%s)', [node, STATION_TYPE.find_key(type), get_instance_id()])
	if type == STATION_TYPE.SEAT:
		node.stop_moving()
		if node.get_parent():
			node.reparent(self)
		else:
			add_child(node)
		var center = get_center()
		if center:
			node.position = center.position

func done_using(node:Actor):
	if not has_user(node):
		return
	var map = TileMapHelper.get_current_map()
	if not map:
		return
	node.reparent(map)
	
## Remove from map
func remove():
	# make users walk away
	for user in get_users():
		done_using(user)
		user.fsm.set_state('Walk')
	get_parent().remove_child(self)
	remove_from_group(GROUP)
	
func _ready():
	add_to_group(GROUP)

func _on_inventory_item_stored(item:Item):
	animation.play('store_item')

func _on_inventory_item_removed(item:Item):
	animation.play('get_item')
