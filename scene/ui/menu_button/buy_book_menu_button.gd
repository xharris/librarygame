extends GameMenuButton

var books:Array[Book] = []

func get_card_objects():
	return Book.GENRE.values().slice(0,3).map(func(v):return Book.GENRE.find_key(v)+'_BOOK')
		
func on_item_pressed(index:int):
	var genre = Book.GENRE.values()[index]
	var actor = Actor.build(Actor.ROLE.SERVICE)
	for i in 3:
		var book = Book.build([genre])
		var inventory := actor.find_child('Inventory') as Inventory
		inventory.add_item(book)
	var map := TileMapHelper.get_current_map() as Map
	map.spawn_actor(actor)
