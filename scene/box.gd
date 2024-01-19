extends Node2D

var inventory = InventoryHelper.Inventory.new(self)

func _enter_tree():
	inventory.add_item(InventoryHelper.Item.create_from_id(1))
