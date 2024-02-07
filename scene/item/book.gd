class_name Book
extends Node2D

enum LENGTH {SHORT, MEDIUM, LONG}

enum GENRE {
	FANTASY, SCIFI, DYSTOPIAN, ACTION, MYSTERY, HORROR, THRILLER, HISTORICAL, ROMANCE, GRAPHIC_NOVEL,
	DRAMA,
	GUIDE, BIOGRAPHY,
}

static var NAME_TEMPLATE = [
	"The {adj1} {noun1}", 
	"{noun1} of {noun2}", 
	"{adj1} {noun1}, {adj2} {noun2}"
]
static var NAME_PARTS = {
	adj = ['poor', 'rich', 'bloody', 'wild', 'secret'],
	noun = ['dad', 'mom', 'heart', 'man', 'woman', 'kid', 'agent', 'killer'],
}

static func register_book(genres:Array[GENRE] = [GENRE.ACTION], color:Color=Palette.Green500, pages:int = 1):
	# generate book name
	var book_name = NAME_TEMPLATE.pick_random()
	var parts:Array[String] = []
	parts.assign(NAME_PARTS.keys())
	var template_args = {}
	for part in parts:
		var i = 1
		while '{'+part+str(i)+'}' in book_name:
			var possible_parts:Array[String] = []
			possible_parts.assign(NAME_PARTS[part])
			template_args[part+str(i)] = (possible_parts.pick_random() as String).capitalize()
			i += 1
	book_name = book_name.format(template_args)
	return Item.register_item(book_name, Item.ITEM_TYPE.BOOK, { genres=genres, color=Palette.Green500, pages=pages })

## Generate `count` random books
## Returns item ids
static func generate(count:int = 1) -> Array[int]:
	var item_ids:Array[int] = []
	for c in count:
		# pick random genres
		var possible_genres = GENRE.values()
		var genre_count = randi_range(1, 3)
		var genres:Array[GENRE] = []
		for i in genre_count:
			var genre = possible_genres.pick_random()
			if possible_genres.size():
				genres.append(genre)
			possible_genres = possible_genres.filter(func(g:int):return g != genre)
		# pick random color
		var color = Palette.pick_random()
		# random page count
		item_ids.append(register_book(genres, color, randi_range(10, 1000)))
	return item_ids

static func get_all_templates() -> Array[Item.ItemTemplate]:
	return Item.get_all().filter(func(i:Item.ItemTemplate):return i.type == Item.ITEM_TYPE.BOOK)

static func get_books(inventory:Inventory) -> Array[Book]:
	var books:Array[Book]
	books.assign(inventory.get_all_items().filter(func(i:Item):return i.type == Item.ITEM_TYPE.BOOK))
	return books

@onready var book_fill:Sprite2D = $Item/BookFill
@onready var item:Item = $Item
var color:Color = Palette.Blue500
var genres:Array[GENRE] = []
var pages = 1

func get_length(pages_read:int = 0) -> LENGTH:
	var length:LENGTH
	match (pages - pages_read):
		var p when p <= 100:
			length = LENGTH.SHORT
		var p when p > 100 and p <= 500:
			length = LENGTH.MEDIUM
		var p when p > 500:
			length = LENGTH.LONG
	return length

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	book_fill.modulate = book_fill.modulate.lerp(color, delta * 5)
