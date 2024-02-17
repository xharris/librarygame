extends Node2D

static var l = Log.new()

func _ready():
	var book_ids = Book.generate()
	var book = Item.create_from_id(book_ids.front())
	var inventories = Inventory.get_all()
	if not inventories.size():
		l.error('No inventories found to store first book')
	var inventory := inventories.front() as Inventory
	inventory.add_item(book)

func _on_map_patron_spawned(actor):
	Modifier.add_modifier(actor, Modifiers.COMFORTABLE)
