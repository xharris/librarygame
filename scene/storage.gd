extends Node2D

var inventory = InventoryHelper.Inventory.new(self)

func _ready():
	inventory.add_item(InventoryHelper.Item.create_from_id(1))
