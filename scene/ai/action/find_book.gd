extends ActionLeaf

@export var item_key:String = 'item'
@export var inventory_key:String = 'inventory'

func item_sort(a:Item, b:Item, actor:Actor):
	return genre_likes(a, actor) < genre_likes(b, actor)

func item_filter(item:Item, actor:Actor):
	if not item.type == Item.TYPE.BOOK:
		return false
	return true

func inventory_filter(inventory:Inventory, actor:Actor):
	if inventory.parent is Actor:
		return false
	var items = inventory.get_all_items()
	items.sort_custom(item_sort.bind(actor))
	if not items.any(item_filter.bind(actor)):
		return false
	return true

func genre_likes(item:Item, actor:Actor) -> int:
	var book = Book.from_item(item)
	return book.genres.filter(func(g:Book.GENRE):return g in actor.likes_genres).size()

func tick(actor, blackboard: Blackboard):
	actor = actor as Actor
	if not actor:
		return FAILURE
	# filter all inventories
	var inventories = Inventory.get_all().filter(inventory_filter.bind(actor))
	if not inventories.size():
		return FAILURE
	# filter items in first inventory
	var items = (inventories.front() as Inventory).get_all_items().filter(item_filter.bind(actor))
	if not items.size():
		return FAILURE
	var item := items.front() as Item
	var inventory := item.get_parent() as Inventory
	if not inventory:
		return FAILURE
	# found book
	blackboard.set_value(inventory_key, inventory)
	blackboard.set_value(item_key, item)
	return SUCCESS

