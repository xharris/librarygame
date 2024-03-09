class_name Station
extends Node2D

static var l = Log.new()
static var GROUP = 'station'
enum STATION_TYPE {SEAT,STORAGE,DOOR}

static func get_all() -> Array[Station]:
	var stations:Array[Station] = []
	stations.assign(Global.get_tree().get_nodes_in_group(GROUP))
	return stations

static func is_using_type(actor:Actor, type:STATION_TYPE) -> bool:
	return get_all().any(func(s:Station):return s.type == type and s.has_user(actor))

@onready var animation:AnimationPlayer = $AnimationPlayer
@export var max_occupancy = 1
@export var type:Station.STATION_TYPE:
	set(value):
		type = value
		notify_property_list_changed()
@export var center:Node2D
@export var cost:int = 2
var enabled = true
var _previous_parent:Dictionary = {}
var map_cell:Vector2i

signal removed

# TODO doesn't work
func _validate_property(property:Dictionary):
	if property.name in ['max_occupancy'] and type != STATION_TYPE.SEAT:
		property.usage = PROPERTY_USAGE_NO_EDITOR

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
		node.reparent(self)
		Events.actor_use_station.emit(node, self)
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
	Events.actor_free_station.emit(node, self)

func get_inventory() -> Inventory:
	return find_child('Inventory') as Inventory

## Remove from map
func remove():
	removed.emit()
	# make users walk away
	for user in get_users():
		done_using(user)
		user.fsm.set_state('Walk')
	# drop inventory
	var inventory = get_inventory()
	if inventory:
		inventory.remove()
	# remove from tree
	get_parent().remove_child(self)
	remove_from_group(GROUP)
	
func _ready():
	add_to_group(GROUP)
	var map = TileMapHelper.get_current_map() as Map
	if map:
		map_cell = map.get_closest_cell(global_position)

func _on_inventory_item_stored(item:Item):
	animation.play('store_item')

func _on_inventory_item_removed(item:Item):
	animation.play('get_item')
