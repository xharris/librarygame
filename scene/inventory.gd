class_name Inventory
extends Node2D

static var l = Log.new()

static var GROUP = 'inventory'
static var scn_map_tile = preload('res://scene/map_tile.tscn')

signal item_stored(item:Item)
signal item_removed(item:Item)

static func get_all() -> Array[Inventory]:
	var objects:Array[Inventory]
	objects.assign(Global.tree().get_nodes_in_group(GROUP).filter(func(i:Inventory): return i.is_active()))
	return objects

static func find_closest(to:Node2D, filter:Callable = Global.CALLABLE_TRUE) -> Inventory:
	var inventory_in_to:Inventory = to.find_child('Inventory')
	var inventories = get_all().\
		filter(func(i:Inventory): return i != inventory_in_to and filter.call(i))
	inventories.sort_custom(func(a:Inventory,b:Inventory): 
		return a.global_position.distance_to(to.global_position) <  b.global_position.distance_to(to.global_position))
	return inventories.front()

## Search all inventories for an item
static func find_inventory_with_item(item_id:int) -> Array[Inventory]:
	return get_all().filter(func(i:Inventory): return i.has_item(item_id))

static func get_inventory(node:Node) -> Inventory:
	return node.find_child('Inventory')

@export var max_size = 9999

func _ready():
	add_to_group(GROUP)

func is_active() -> bool:
	return find_parent('Map') != null

## Returns true if inventory belongs to node
func belongs_to(node:Node2D):
	return node.find_child('Inventory') == self
	
func has_item_type(type:Item.TYPE) -> bool:
	var items := get_all_items()
	return items.any(func(i:Item): return i.type == type)

func is_full() -> bool:
	return get_all_items().size() >= max_size

func add_item(item:Item) -> Inventory:
	if not is_full():
		add_child(item)
		item_stored.emit(item)
		_adjust_item_positions()
	return self

func get_all_items() -> Array[Item]:
	var items:Array[Item]
	items.assign(get_children().filter(func(c:Node): return c is Item))
	return items

func size() -> int:
	return get_all_items().size()

func remove_item(item:Item) -> bool:
	if item.get_parent() == self:
		remove_child(item)
		item_removed.emit(item)
		_adjust_item_positions()
		return true
	return false

## Move an item from one inventory to another
## Returns true on success
## TODO show item bouncing from this inventory to other one
func transfer_item(item:Item, to:Inventory) -> bool:
	if not to or to.is_full() or not is_active():
		return false
	# find item
	if not remove_item(item):
		return false
	# move to other inventory
	to.add_item(item)
	return true

func remove():
	# drop items on ground
	for item in get_all_items():
		drop_item(item)
	remove_from_group(GROUP)

## Returns true if item was succesfully dropped
func drop_item(item:Item):
	var parent = get_parent()
	if not parent:
		l.error('Missing parent (%s)', [get_instance_id()])
		return false
	var map := TileMapHelper.get_current_map() as Map
	if not map:
		l.error('Not on map (%s)', [get_instance_id()])
		return false
	l.debug('drop item %d', [item])
	var node_cell = map.get_closest_cell(global_position)
	# Get MapTile at node (if it exists)
	var map_tiles = get_tree().get_nodes_in_group(MapTile.GROUP).filter(func(m:MapTile):return m.cell == node_cell)
	var map_tile:MapTile
	if map_tiles.size():
		map_tile = map_tiles.front()
	if not map_tile:
		# Create a new map tile under the node
		map_tile = scn_map_tile.instantiate() as MapTile
		map_tile.cell = node_cell
		map_tile.global_position = map.to_global(map.map_to_local(node_cell))
		map.add_child(map_tile)
	return transfer_item(item, map_tile.inventory)

func _adjust_item_positions():
	var i = 0
	for item in get_all_items():
		item.position = Vector2(0,-i*3)
		i += 1
