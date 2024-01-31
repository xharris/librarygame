extends Node2D

@onready var first_box := $Map/Box
var first_book_id:int

func _ready():
	first_book_id = Item.register_item('rich dad poor dad', Item.ITEM_TYPE.BOOK, { color=Palette.Green500 })
	var inventory := first_box.find_child('Inventory') as Inventory
	if inventory:
		inventory.add_item(Item.create_from_id(first_book_id))


func _on_map_spawn_patron(actor:Actor):
	var read_state := actor.fsm.find_state('Read') as Read
	if read_state:
		read_state.book_list = [first_book_id]
