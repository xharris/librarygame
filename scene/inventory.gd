class_name Inventory
extends Node2D

static var l = Log.new()

static var instances: Array[Inventory]
static var scn_map_tile = preload('res://scene/map_tile.tscn')

signal item_stored
signal item_removed

static func find_closest(to:Node2D) -> Inventory:
	var other_instances = instances.filter(func(i:Inventory): return i.node != to)
	other_instances.sort_custom(func(a:Inventory,b:Inventory): 
		return a.node.global_position.distance_to(to.global_position) <  b.node.global_position.distance_to(to.global_position)
	)
	return other_instances.front()

## Search all inventories for an item
static func find_inventory_with_item(item_id:int) -> Array[Inventory]:
	return Inventory.instances.filter(func(i:Inventory): return i.has_item(item_id))

var node:Node2D
var disabled = false

func _enter_tree():
	node = get_parent()
	instances.append(self)

func has_item(id:int) -> bool:
	var items := get_all_items()
	return items.any(func(i:Item): return i.id == id)
	
func has_item_type(type:Item.ITEM_TYPE) -> bool:
	var items := get_all_items()
	return items.any(func(i:Item): return i.type == type)
	
func add_item(item:Item) -> Inventory:
	add_child(item)
	item_stored.emit(item)
	return self

func get_all_items() -> Array[Item]:
	var items:Array[Item]
	items.assign(get_children().filter(func(c:Node): return c is Item))
	return items

func get_items(id:int) -> Array[Item]:
	var items := get_all_items()
	return items.filter(func(i:Item): return i.id == id)

func remove_item(item_id:int) -> Item:
	var items := get_all_items()
	var found_item:Item
	for item in items:
		if item.id == item_id:
			found_item = item
	if found_item:
		remove_child(found_item)
		item_removed.emit(found_item)
	return found_item

## Move an item from one inventory to another
## Returns true on success
## TODO show item bouncing from this inventory to other one
func transfer_item(item_id:int, to:Inventory) -> bool:
	if to.disabled:
		return false
	# find item
	var removed_item = remove_item(item_id)
	if not removed_item:
		return false
	l.debug('transfer item %s from %s to %s', [item_id, node, to.get_parent()])
	# move to other inventory
	to.add_item(removed_item)
	return true
	
## Returns true if item was succesfully dropped
func drop_item(item_id:int):
	var map := TileMapHelper.get_current_map() as Map
	if not map:
		return false
	var node_cell = map.map_to_local(map.to_local(node.global_position))
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

func _on_tree_exiting():
	# drop items on ground
	for item in get_all_items():
		drop_item(item.id)
