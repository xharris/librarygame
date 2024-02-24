extends AddCardsButton

var books:Array[Book] = []

func get_card_objects():
	return ['action_book']

func on_card_pressed(event:InputEvent, card:SmallCard):
	var actor = Actor.build(Actor.ROLE.SERVICE)
	for i in 3:
		var book = Book.build()
		var inventory := actor.find_child('Inventory') as Inventory
		inventory.add_item(book)
	
	var map := TileMapHelper.get_current_map() as Map
	map.spawn_actor(actor)

func _ready():
	pass # TODO generate books?
