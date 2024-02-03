class_name Inventory
extends Node2D

static var l = Log.new(Log.LEVEL.DEBUG)

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
	inventories\
		.sort_custom(func(a:Inventory,b:Inventory): 
			return a.global_position.distance_to(to.global_position) <  b.global_position.distance_to(to.global_position))
	return inventories.front()

## Search all inventories for an item
static func find_inventory_with_item(item_id:int) -> Array[Inventory]:
	return get_all().filter(func(i:Inventory): return i.has_item(item_id))

@export var max_size = 9999
@export var parent:Node2D

func _ready():
	add_to_group(GROUP)

func is_active() -> bool:
	return find_parent('Map') != null

## Returns true if inventory belongs to node
func belongs_to(node:Node2D):
	return node.find_child('Inventory') == self

func has_item(id:int) -> bool:
	var items := get_all_items()
	return items.any(func(i:Item): return i.id == id)
	
func has_item_type(type:Item.ITEM_TYPE) -> bool:
	var items := get_all_items()
	return items.any(func(i:Item): return i.type == type)

func is_full() -> bool:
	return get_all_items().size() >= max_size

func add_item(node:Node2D) -> Inventory:
	if not is_active():
		return self
	var item = Item.get_item_node(node)
	if not is_full() and item:
		add_child(node)
		item_stored.emit(item)
	return self

func get_all_items() -> Array[Item]:
	var items:Array[Item]
	items.assign(get_children().map(func(c:Node2D):return Item.get_item_node(c)).filter(func(c:Node): return c != null))
	return items

func get_items(id:int) -> Array[Item]:
	var items := get_all_items()
	return items.filter(func(i:Item): return i.id == id)

func remove_item(item_id:int) -> Node2D:
	var items := get_all_items()
	var found_child:Node2D
	for item in items:
		if item.id == item_id:
			found_child = item.get_parent()
	if found_child:
		remove_child(found_child)
		item_removed.emit(Item.get_item_node(found_child))
	return found_child

## Move an item from one inventory to another
## Returns true on success
## TODO show item bouncing from this inventory to other one
func transfer_item(item_id:int, to:Inventory) -> bool:
	if not to or to.is_full() or not is_active():
		return false
	# find item
	var removed_item = remove_item(item_id)
	if not removed_item:
		return false
	l.debug('transfer item %s from %s to %s', [item_id, parent, to.parent])
	# move to other inventory
	to.add_item(removed_item)
	return true

func remove():
	# drop items on ground
	for item in get_all_items():
		drop_item(item.id)
	remove_from_group(GROUP)

## Returns true if item was succesfully dropped
func drop_item(item_id:int):
	var parent = get_parent()
	if not parent:
		l.error('Missing parent (%s)', [get_instance_id()])
		return false
	var map := TileMapHelper.get_current_map() as Map
	if not map:
		l.error('Not on map (%s)', [get_instance_id()])
		return false
	l.debug('%s drop item %d', [parent, item_id])
	var node_cell = map.map_to_local(map.to_local(parent.global_position))
	# Get MapTile at node (if it exists)
	var map_tiles = get_tree().get_nodes_in_group(MapTile.GROUP).filter(func(m:MapTile):return m.cell == node_cell)
	var map_tile:MapTile
	if map_tiles.size():
		map_tile = map_tiles.front()
	if not map_tile:
		# Create a new map tile under the node
		map_tile = scn_map_tile.instantiate()
		map_tile.global_position = map.to_global(map.map_to_local(node_cell))
		map.add_child(map_tile)
	return transfer_item(item_id, map_tile.inventory)

