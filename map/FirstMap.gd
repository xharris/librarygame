extends Node2D

@onready var first_box := $Map/Tray
var first_book_id:int

func _ready():
	first_book_id = Item.register_item('rich dad poor dad', Item.ITEM_TYPE.BOOK, { color=Palette.Green500 })
	var inventory := first_box.find_child('Inventory') as Inventory
	if inventory:
		inventory.add_item(Item.create_from_id(first_book_id))

func _on_map_patron_spawned(actor):
	var read_task := actor.task_manager.find_task('Read') as Read
	if read_task:
		read_task.book_list = [first_book_id]
