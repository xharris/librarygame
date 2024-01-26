extends Station

func _ready():
	var inventory = $Inventory
	inventory.add_item(Item.create_from_id(1))

func remove():
	var inventory = $Inventory
	# drop items on ground
	for item in inventory.items:
		inventory.drop_item(item)
	super()
